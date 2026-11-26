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

test('HOS-1: No name, however written, puts a line break or a control character in a header.', async () => {
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

// A post's field and a value of a length drawn either side of its limit,
// often one either side of it so the bound itself is met. An
// email's local part takes any length before a fixed domain, since the
// standard bounds no local part, so it makes a valid address of that length.
const domain = '@example.io';
const filled = {
  name: (length) => 'x'.repeat(length),
  message: (length) => 'x'.repeat(length),
  email: (length) => `${'x'.repeat(length - domain.length)}${domain}`,
};
const shortest = { name: 1, message: 1, email: domain.length + 1 };
const anyField = fc.constantFrom(...Object.keys(filled)).chain((field) =>
  fc
    .oneof(
      fc.integer({ min: shortest[field], max: limits[field] + 50 }),
      fc.integer({ min: limits[field] - 1, max: limits[field] + 1 }),
    )
    .map((length) => ({ field, length })),
);

test("HOS-2: Each of a post's name, email and message is read for sending exactly while it is within its limit, the others within theirs.", async () => {
  await fc.assert(
    fc.asyncProperty(anyField, async ({ field, length }) => {
      const reading = await readMessage(post({ ...sam, [field]: filled[field](length) }));
      assert.equal(reading.kind, length <= limits[field] ? 'message' : 'unreadable');
    }),
    { numRuns: 300 },
  );
});
