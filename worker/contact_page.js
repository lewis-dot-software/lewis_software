// The contact page as the Worker answers a post with it, for a reader whose
// browser runs no script: the form, kept as written under its alert, or the
// panel that takes its place once the message is sent.

/** @typedef {import('./message.js').Fields} Fields */

/**
 * The state a post leaves the page in.
 * @typedef {{kind: 'sent'} | {kind: 'failed', fields: Fields}} Outcome
 */

/**
 * [page], the contact page as the build wrote it, rewritten to [outcome].
 * @param {Response} page
 * @param {Outcome} outcome
 * @returns {Response}
 */
export const contactPage = (page, outcome) => {
  const rewriter = new HTMLRewriter();
  switch (outcome.kind) {
    case 'sent':
      rewriter
        .on('#contact-form', { element: (form) => form.setAttribute('hidden', '') })
        .on('#contact-sent', { element: (panel) => panel.removeAttribute('hidden') });
      break;
    case 'failed': {
      const { fields } = outcome;
      rewriter
        .on('#contact-failed', { element: (alert) => alert.removeAttribute('hidden') })
        .on('#contact-send', { element: (button) => button.setInnerContent('Try again') })
        .on('#contact-form input[name="name"]', {
          element: (input) => input.setAttribute('value', fields.name),
        })
        .on('#contact-form input[name="email"]', {
          element: (input) => input.setAttribute('value', fields.email),
        })
        .on('#contact-form textarea[name="message"]', {
          element: (textarea) => textarea.setInnerContent(fields.message),
        })
        .on('#contact-form input[name="topic"]', {
          element: (radio) => {
            if (radio.getAttribute('value') === fields.topic) radio.setAttribute('checked', '');
          },
        });
      break;
    }
    default:
      throw new Error(`An outcome the page has no state for: ${outcome.kind}`);
  }
  return rewriter.transform(page);
};
