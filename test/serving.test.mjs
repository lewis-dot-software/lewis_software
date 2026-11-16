// The build served as Cloudflare serves it: Wrangler runs the Worker from
// wrangler.jsonc whole, its assets routed and their `_headers` applied, with
// the mail binding simulated. Run after a build.
import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { parse } from 'node-html-parser';
import { unstable_startWorker } from 'wrangler';

let worker;

before(async () => {
  worker = await unstable_startWorker({
    config: 'wrangler.jsonc',
    dev: { server: { port: 0 }, inspector: false, logLevel: 'none' },
  });
  await worker.ready;
});

after(() => worker.dispose());

// A post the route reads but cannot send, so nothing reaches the binding.
const unsendable = () =>
  worker.fetch('https://lewis.software/contact', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: 'name=&email=sam%40example.com&message=Hello',
  });

test('the contact page is served at its path, its form posting there', async () => {
  const response = await worker.fetch('https://lewis.software/contact');
  assert.equal(response.status, 200);
  const form = parse(await response.text()).querySelector('#contact-form');
  assert.equal(form.getAttribute('action'), '/contact');
  assert.equal(form.getAttribute('method'), 'post');
});

test("the site's policy lets its pages post forms to the site alone", async () => {
  const response = await worker.fetch('https://lewis.software/contact');
  await response.text();
  assert.match(response.headers.get('content-security-policy'), /(^|; )form-action 'self'(;|$)/);
});

test("a post to the contact page reaches the Worker, whose answer carries the site's headers", async () => {
  const response = await unsendable();
  assert.equal(response.status, 400);
  const document = parse(await response.text());
  assert.equal(document.querySelector('#contact-failed').hasAttribute('hidden'), false);
  const page = await worker.fetch('https://lewis.software/contact');
  await page.text();
  for (const header of ['content-security-policy', 'permissions-policy', 'referrer-policy', 'strict-transport-security']) {
    assert.equal(response.headers.get(header), page.headers.get(header), header);
    assert.ok(response.headers.get(header), header);
  }
});

test('a post to any other page is refused, never sent', async () => {
  const response = await worker.fetch('https://lewis.software/', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: 'name=Sam&email=sam%40example.com&message=Hello',
  });
  await response.text();
  assert.equal(response.status, 405);
});
