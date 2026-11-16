// lewis.software's Worker. The site is its static assets, and the one route
// it answers itself is the contact form's post: it sends the message to Dan
// by email, with the sender's address as its reply-to, and keeps nothing.

import { contactPage } from './contact_page.js';
import { readMessage } from './message.js';

/** The contact page's path, where its form posts. */
const contactPath = '/contact';

/**
 * Answers a post to the contact page: sends its message, then shows the page
 * in the state the send left it, with the status that says how it went.
 * @param {Request} request
 * @param {{ASSETS: Fetcher, EMAIL: {send: (email: object) => Promise<unknown>}}} env
 * @returns {Promise<Response>}
 */
const contact = async (request, env) => {
  const reading = await readMessage(request);
  let outcome;
  let status;
  switch (reading.kind) {
    case 'unreadable':
      outcome = { kind: 'failed', fields: reading.fields };
      status = 400;
      break;
    case 'message':
      try {
        await env.EMAIL.send(reading.email);
        outcome = { kind: 'sent' };
        status = 200;
      } catch (error) {
        // The binding throws its failures with a code, and anything else is
        // a bug, which is thrown on.
        if (typeof error?.code !== 'string') throw error;
        console.error(`The contact form's message did not send: ${error.code}`);
        outcome = { kind: 'failed', fields: reading.fields };
        status = 502;
      }
      break;
    default:
      throw new Error(`A reading the route has no answer for: ${reading.kind}`);
  }
  const page = await env.ASSETS.fetch(new URL(contactPath, request.url));
  if (!page.ok) throw new Error(`The contact page is missing from the build: ${page.status}`);
  const headers = new Headers(page.headers);
  // The page answers this post alone, so no cache keeps it.
  headers.delete('etag');
  headers.set('cache-control', 'no-store');
  return new Response(contactPage(page, outcome).body, { status, headers });
};

export default {
  /**
   * @param {Request} request
   * @param {{ASSETS: Fetcher, EMAIL: {send: (email: object) => Promise<unknown>}}} env
   */
  fetch: (request, env) => {
    if (new URL(request.url).pathname === contactPath && request.method === 'POST') {
      return contact(request, env);
    }
    return env.ASSETS.fetch(request);
  },
};
