// A message posted from the contact form, read from the request's form data
// into the email that carries it to Dan. Nothing here keeps what it reads.

/** The address every message is sent to, and the only one. */
export const recipient = 'dan@lewis.software';

/** The address every message is sent from, on the site's own domain. */
export const sender = { email: 'contact@lewis.software', name: 'lewis.software' };

/** The topics the form offers, each by the words it sends for it. */
export const topics = Object.freeze([
  'An existing tool or app',
  'An app or website built for you',
  'Anything else',
]);

/**
 * The most characters each field the sender fills in takes, as the form's
 * `maxlength` holds it, its line breaks counted as one character each.
 */
export const limits = Object.freeze({ name: 200, email: 254, message: 10000 });

/** The most bytes of form data the route reads, well past what the limits allow. */
export const bodyLimit = 128 * 1024;

// The HTML standard's valid email address, the one a browser checks
// `type="email"` against, so the route takes what the form let through.
const validEmail =
  /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;

/**
 * What the sender wrote, each field as posted with its line breaks made `\n`,
 * and an empty string where a field was missing or no topic was chosen.
 * @typedef {{topic: string, name: string, email: string, message: string}} Fields
 */

/**
 * The outcome of reading a post: a message ready to send, or fields that do
 * not make one.
 * @typedef {{kind: 'message', fields: Fields, email: object}
 *   | {kind: 'unreadable', fields: Fields}} Reading
 */

/** No fields at all, for a post whose form data could not be read. */
const noFields = Object.freeze({ topic: '', name: '', email: '', message: '' });

/**
 * [value] on one line, each run of whitespace and control characters one
 * space, so nothing in it can end a header.
 */
const oneLine = (value) => value.replace(/[\s\p{Cc}]+/gu, ' ').trim();

/**
 * Reads [request]'s form data.
 * @param {Request} request
 * @returns {Promise<Reading>}
 */
export const readMessage = async (request) => {
  const length = Number(request.headers.get('content-length'));
  if (!Number.isInteger(length) || length <= 0 || length > bodyLimit) {
    return { kind: 'unreadable', fields: noFields };
  }
  let form;
  try {
    form = await request.formData();
  } catch (error) {
    // A body that is not form data is the sender's to mend, never a bug here.
    if (!(error instanceof TypeError)) throw error;
    return { kind: 'unreadable', fields: noFields };
  }
  /** @type {Fields} */
  const fields = Object.fromEntries(
    Object.keys(noFields).map((key) => {
      const value = form.get(key);
      return [key, typeof value === 'string' ? value.replace(/\r\n?/g, '\n') : ''];
    }),
  );
  const { topic } = fields;
  const name = oneLine(fields.name);
  const email = fields.email.trim();
  const message = fields.message.trim();
  const fits = Object.entries(limits).every(([key, limit]) => fields[key].length <= limit);
  const chosen = topic === '' || topics.includes(topic);
  if (!fits || !chosen || name === '' || message === '' || !validEmail.test(email)) {
    return { kind: 'unreadable', fields };
  }
  return {
    kind: 'message',
    fields,
    email: {
      from: sender,
      to: recipient,
      replyTo: { email, name },
      subject: topic === '' ? `A message from ${name}` : `${topic}, from ${name}`,
      text: [`From: ${name} <${email}>`, ...(topic === '' ? [] : [`Topic: ${topic}`]), '', message].join('\n'),
    },
  };
};
