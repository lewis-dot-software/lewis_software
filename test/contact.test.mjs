// web/contact.js, run against a fake browser: the form, its alert, its button
// and the sent panel, with `fetch` answered as each test says.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import vm from 'node:vm';

const script = readFileSync(new URL('../web/contact.js', import.meta.url), 'utf8');

// An element with the parts the script reads and writes.
const element = (props = {}) => ({ hidden: false, disabled: false, textContent: '', focused: false, focus() { this.focused = true; }, ...props });

// Runs contact.js in a fake browser whose `fetch` answers as [answer] does,
// and returns the handles a test drives it by.
const browser = (answer) => {
  const listeners = {};
  const posts = [];
  const form = element({
    action: 'https://lewis.software/contact',
    fields: [['topic', 'Anything else'], ['name', 'Sam'], ['email', 'sam@example.com'], ['message', 'Hello']],
    addEventListener: (type, listener) => {
      listeners[type] = listener;
    },
  });
  const failed = element({ hidden: true });
  const sent = element({ hidden: true });
  const button = element({ textContent: 'Send message' });
  const elements = { 'contact-form': form, 'contact-failed': failed, 'contact-sent': sent, 'contact-send': button };
  // The button as it stood while the request was out.
  let whileOut;
  vm.runInNewContext(script, {
    TypeError,
    URLSearchParams,
    FormData: function FormData(of) {
      return of.fields;
    },
    fetch: async (url, init) => {
      whileOut = { text: button.textContent, disabled: button.disabled, alert: failed.hidden };
      posts.push({ url, method: init.method, body: init.body.toString() });
      return answer();
    },
    document: { getElementById: (id) => elements[id] },
  });
  return {
    form,
    failed,
    sent,
    button,
    posts,
    whileOut: () => whileOut,
    submit: async () => {
      let prevented = false;
      await listeners.submit({ preventDefault: () => (prevented = true) });
      return prevented;
    },
  };
};

test('a send posts the form where it would post without script, and stays on the page', async () => {
  const page = browser(() => ({ ok: true }));
  assert.equal(await page.submit(), true);
  assert.deepEqual(page.posts, [
    {
      url: 'https://lewis.software/contact',
      method: 'POST',
      body: 'topic=Anything+else&name=Sam&email=sam%40example.com&message=Hello',
    },
  ]);
});

test('while the request is out, the button reads Sending and is disabled', async () => {
  const page = browser(() => ({ ok: true }));
  await page.submit();
  assert.deepEqual(page.whileOut(), { text: 'Sending', disabled: true, alert: true });
});

test('a sent message puts the panel in the form\'s place, and moves the reader to it', async () => {
  const page = browser(() => ({ ok: true }));
  await page.submit();
  assert.equal(page.form.hidden, true);
  assert.equal(page.sent.hidden, false);
  assert.equal(page.sent.focused, true);
  assert.equal(page.failed.hidden, true);
});

for (const [why, answer] of [
  ['an answer that says it failed', () => ({ ok: false })],
  ['a request that never reaches the Worker', () => Promise.reject(new TypeError('offline'))],
]) {
  test(`${why} shows the alert over the form as written, its button reading Try again`, async () => {
    const page = browser(answer);
    await page.submit();
    assert.equal(page.form.hidden, false);
    assert.equal(page.sent.hidden, true);
    assert.equal(page.failed.hidden, false);
    assert.equal(page.button.textContent, 'Try again');
    assert.equal(page.button.disabled, false);
  });
}

test('a try again hides the alert while the request is out', async () => {
  let ok = false;
  const page = browser(() => ({ ok }));
  await page.submit();
  ok = true;
  await page.submit();
  assert.equal(page.whileOut().alert, true);
  assert.equal(page.sent.hidden, false);
});

test('a bug in the request is thrown', async () => {
  const page = browser(() => Promise.reject(new RangeError('bug')));
  await assert.rejects(page.submit(), RangeError);
});
