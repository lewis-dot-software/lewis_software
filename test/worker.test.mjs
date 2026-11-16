// worker/index.js, run in workerd by Miniflare and handed each request
// itself, so the route is read apart from how the assets route to it, which
// serving.test.mjs reads. Its assets binding serves the contact page the
// build wrote, so run it after a build. Its mail binding is a fake that keeps
// each email it is handed, and fails a send with the code a test gives it.
import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import { convertV4MiniflareOptions, Miniflare } from 'miniflare';
import { parse } from 'node-html-parser';

import { bodyLimit, limits, recipient, sender, topics } from '../worker/message.js';

// wrangler.jsonc holds no comment, so it parses as JSON.
const config = JSON.parse(readFileSync(new URL('../wrangler.jsonc', import.meta.url), 'utf8'));

// The emails the fake binding was handed, and how the next send fails, if it
// does: refused with the binding's code, or broken by a bug.
let outbox = [];
let failure = null;

const mailer = `
import { WorkerEntrypoint } from 'cloudflare:workers';
export class Mailer extends WorkerEntrypoint {
  async send(email) {
    const answer = await this.env.POST_OFFICE.fetch('http://post-office/', {
      method: 'POST',
      body: JSON.stringify(email),
    });
    switch (answer.status) {
      case 200:
        break;
      case 502: {
        const error = new Error('The fake binding refused the send.');
        error.code = await answer.text();
        throw error;
      }
      default:
        throw new TypeError('The fake binding broke.');
    }
    return { messageId: 'fake' };
  }
}`;

let mf;

before(async () => {
  const [binding] = config.send_email;
  mf = new Miniflare(convertV4MiniflareOptions({
    workers: [
      {
        name: config.name,
        // The entry first, then every other module beside it.
        modules: [
          config.main,
          ...readdirSync('worker')
            .map((file) => `worker/${file}`)
            .filter((path) => path !== config.main),
        ].map((path) => ({ type: 'ESModule', path })),
        compatibilityDate: config.compatibility_date,
        serviceBindings: {
          [config.assets.binding]: (request) =>
            new URL(request.url).pathname === '/contact'
              ? new Response(readFileSync('build/jaspr/contact/index.html'), {
                  headers: { 'content-type': 'text/html; charset=utf-8', etag: '"built"' },
                })
              : new Response('Not found', { status: 404 }),
          [binding.name]: { name: 'mailer', entrypoint: 'Mailer' },
        },
      },
      {
        name: 'mailer',
        modules: true,
        script: mailer,
        compatibilityDate: config.compatibility_date,
        serviceBindings: {
          POST_OFFICE: async (request) => {
            outbox.push(await request.json());
            switch (failure?.kind) {
              case undefined:
                return new Response('sent');
              case 'refused':
                return new Response(failure.code, { status: 502 });
              case 'bug':
                return new Response('broken', { status: 500 });
              default:
                throw new Error(`A failure the fake has no answer for: ${failure.kind}`);
            }
          },
        },
      },
    ],
  }));
  await mf.ready;
});

after(() => mf.dispose());

beforeEach(() => {
  outbox = [];
  failure = null;
});

const sam = {
  topic: 'An app or website built for you',
  name: 'Sam Carter',
  email: 'sam@example.com',
  message: 'Hello, I run a small bakery.\r\nCould you build an app?',
};

// Posts [fields] to the contact page as a browser posts its form.
const post = (fields, init = {}) =>
  mf.dispatchFetch('https://lewis.software/contact', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams(fields).toString(),
    ...init,
  });

const page = async (response) => parse(await response.text());

test('a post sends one email to Dan, from the site, with the sender as its reply-to', async () => {
  const response = await post(sam);
  assert.equal(response.status, 200);
  assert.deepEqual(outbox, [
    {
      from: sender,
      to: recipient,
      replyTo: { email: 'sam@example.com', name: 'Sam Carter' },
      subject: 'An app or website built for you, from Sam Carter',
      text:
        'From: Sam Carter <sam@example.com>\n' +
        'Topic: An app or website built for you\n' +
        '\n' +
        'Hello, I run a small bakery.\nCould you build an app?',
    },
  ]);
  assert.equal(recipient, 'dan@lewis.software');
  assert.equal(config.send_email[0].destination_address, recipient);
  assert.deepEqual(config.send_email[0].allowed_sender_addresses, [sender.email]);
});

test('a post with no topic sends with none', async () => {
  await post({ ...sam, topic: '' });
  assert.equal(outbox[0].subject, 'A message from Sam Carter');
  assert.equal(outbox[0].text, 'From: Sam Carter <sam@example.com>\n\nHello, I run a small bakery.\nCould you build an app?');
});

test('a name over lines is sent on one, so no header can be written through it', async () => {
  await post({ ...sam, name: 'Sam\r\nBcc: eve@example.com' });
  assert.equal(outbox[0].replyTo.name, 'Sam Bcc: eve@example.com');
  assert.doesNotMatch(outbox[0].subject, /[\r\n]/);
});

test('a sent post answers with the page, its form hidden and its sent panel shown', async () => {
  const document = await page(await post(sam));
  assert.equal(document.querySelector('#contact-form').hasAttribute('hidden'), true);
  assert.equal(document.querySelector('#contact-sent').hasAttribute('hidden'), false);
  assert.equal(document.querySelector('#contact-sent h2').text, 'Message sent.');
});

test('a failed send answers 502 with the form as written, under its alert', async () => {
  failure = { kind: 'refused', code: 'E_DELIVERY_FAILED' };
  const response = await post({ ...sam, name: 'Sam "Quotes" <Carter>' });
  assert.equal(response.status, 502);
  const document = await page(response);
  const form = document.querySelector('#contact-form');
  assert.equal(form.hasAttribute('hidden'), false);
  assert.equal(document.querySelector('#contact-sent').hasAttribute('hidden'), true);
  assert.equal(document.querySelector('#contact-failed').hasAttribute('hidden'), false);
  assert.equal(document.querySelector('#contact-send').text, 'Try again');
  assert.equal(form.querySelector('input[name="name"]').getAttribute('value'), 'Sam "Quotes" <Carter>');
  assert.equal(form.querySelector('input[name="email"]').getAttribute('value'), sam.email);
  assert.equal(form.querySelector('textarea[name="message"]').text, 'Hello, I run a small bakery.\nCould you build an app?');
  assert.deepEqual(
    form.querySelectorAll('input[name="topic"]').map((radio) => [radio.getAttribute('value'), radio.hasAttribute('checked')]),
    [
      ['An existing tool or app', false],
      ['An app or website built for you', true],
      ['Anything else', false],
    ],
  );
});

test('words that look like markup are kept as words', async () => {
  failure = { kind: 'refused', code: 'E_DELIVERY_FAILED' };
  const message = '</textarea><script>alert(1)</script>';
  const document = await page(await post({ ...sam, message }));
  assert.equal(document.querySelectorAll('script:not([src])').length, 0);
  assert.equal(document.querySelector('textarea[name="message"]').text, message);
});

for (const [why, fields] of [
  ['no name', { ...sam, name: '  ' }],
  ['no message', { ...sam, message: '\n' }],
  ['an address a browser would refuse', { ...sam, email: 'sam at example.com' }],
  ['a name past its limit', { ...sam, name: 'n'.repeat(limits.name + 1) }],
  ['an address past its limit', { ...sam, email: `${'e'.repeat(limits.email)}@x.io` }],
  ['a message past its limit', { ...sam, message: 'm'.repeat(limits.message + 1) }],
  ['a topic the form does not offer', { ...sam, topic: 'Invoice overdue' }],
]) {
  test(`a post with ${why} sends nothing, and answers 400 with the form as written`, async () => {
    const response = await post(fields);
    assert.equal(response.status, 400);
    assert.deepEqual(outbox, []);
    const document = await page(response);
    assert.equal(document.querySelector('#contact-failed').hasAttribute('hidden'), false);
    assert.equal(document.querySelector('input[name="email"]').getAttribute('value'), fields.email);
  });
}

test('a message at its limit counts each line break once, as the form does', async () => {
  const message = `${'m'.repeat(limits.message - 2)}\r\nm`;
  assert.equal((await post({ ...sam, message })).status, 200);
});

test('a body that is not form data, or past the limit, sends nothing', async () => {
  const notForm = await mf.dispatchFetch('https://lewis.software/contact', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(sam),
  });
  assert.equal(notForm.status, 400);
  const tooLong = await post({ ...sam, message: 'm'.repeat(bodyLimit) });
  assert.equal(tooLong.status, 400);
  assert.deepEqual(outbox, []);
});

test("a bug in the binding is thrown, never shown as the sender's failure", async () => {
  failure = { kind: 'bug' };
  const response = await post(sam);
  assert.equal(response.status, 500);
});

test('the answer to a post is never cached', async () => {
  const response = await post(sam);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.equal(response.headers.get('etag'), null);
  assert.match(response.headers.get('content-type'), /^text\/html/);
});

test("the form's limits are the route's", () => {
  const form = parse(readFileSync('build/jaspr/contact/index.html', 'utf8')).querySelector('#contact-form');
  for (const field of ['name', 'email', 'message']) {
    assert.equal(Number(form.querySelector(`[name="${field}"]`).getAttribute('maxlength')), limits[field], field);
  }
});

test("the form's topics are the route's", () => {
  const form = parse(readFileSync('build/jaspr/contact/index.html', 'utf8')).querySelector('#contact-form');
  assert.deepEqual(
    form.querySelectorAll('input[name="topic"]').map((radio) => radio.getAttribute('value')),
    topics,
  );
});

