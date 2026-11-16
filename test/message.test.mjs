// worker/message.js's reading of a post, held over generated inputs: what
// reaches the email's headers, and the bound on each field.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import fc from 'fast-check';

import { limits, readMessage } from '../worker/message.js';

// A post of [fields] as a browser sends the form, its length declared.
const post = (fields) => {
  const body = new URLSearchParams(fields).toString();
  return new Request('https://lewis.software/contact', {
    method: 'POST',
    headers: {
      'content-type': 'application/x-www-form-urlencoded',
      'content-length': String(new TextEncoder().encode(body).length),
    },
    body,
  });
};

const sam = { name: 'Sam', email: 'sam@example.com', message: 'Hello' };

// A control character or a line break, which would end a header.
const breaksHeader = /[\p{Cc}\u2028\u2029]/u;

test('no name, however written, puts a line break or a control character in a header', async () => {
  const anyText = fc.string({ unit: 'binary', maxLength: limits.name });
  const breaking = fc.constantFrom('\r', '\n', '\r\n', '\u0000', '\u0085', '\u2028', '\t');
  const name = fc
    .array(fc.oneof(anyText, breaking), { minLength: 1, maxLength: 6 })
    .map((parts) => parts.join('').slice(0, limits.name));
  await fc.assert(
    fc.asyncProperty(name, async (name) => {
      const reading = await readMessage(post({ ...sam, name }));
      if (reading.kind !== 'message') return;
      assert.doesNotMatch(reading.email.subject, breaksHeader);
      assert.doesNotMatch(reading.email.replyTo.name, breaksHeader);
    }),
  );
});

for (const field of ['name', 'message']) {
  test(`a ${field} is read for sending exactly while it is within its limit`, async () => {
    await fc.assert(
      fc.asyncProperty(fc.integer({ min: 1, max: limits[field] + 50 }), async (length) => {
        const reading = await readMessage(post({ ...sam, [field]: 'x'.repeat(length) }));
        assert.equal(reading.kind, length <= limits[field] ? 'message' : 'unreadable');
      }),
    );
  });
}

test('an email is read for sending exactly while it is within its limit', async () => {
  // The standard sets no bound on an address's local part, so one of any
  // length before a fixed domain makes a valid address of that length.
  const domain = '@example.io';
  await fc.assert(
    fc.asyncProperty(fc.integer({ min: domain.length + 1, max: limits.email + 50 }), async (length) => {
      const email = `${'x'.repeat(length - domain.length)}${domain}`;
      const reading = await readMessage(post({ ...sam, email }));
      assert.equal(reading.kind, length <= limits.email ? 'message' : 'unreadable');
    }),
  );
});
