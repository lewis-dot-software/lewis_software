// lewis.software's contact form, sent without leaving the page. The form
// posts to the site's Worker as it would without script, and the page shows
// what came of it: the sent panel in the form's place, or the alert above the
// form, kept as written. Without script the Worker answers the post with the
// page in the same state.
(() => {
  const form = document.getElementById('contact-form');
  const sent = document.getElementById('contact-sent');
  const failed = document.getElementById('contact-failed');
  const button = document.getElementById('contact-send');

  // A request that never reaches the Worker rejects with a TypeError, and is
  // as much a failure to send as an answer that says so. Any other error is a
  // bug, and is thrown.
  const post = async () => {
    try {
      return await fetch(form.action, {
        method: 'POST',
        body: new URLSearchParams(new FormData(form)),
      });
    } catch (error) {
      if (!(error instanceof TypeError)) throw error;
      return null;
    }
  };

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    failed.hidden = true;
    button.disabled = true;
    button.textContent = 'Sending';
    const response = await post();
    if (response?.ok) {
      form.hidden = true;
      sent.hidden = false;
      sent.focus();
    } else {
      failed.hidden = false;
      button.textContent = 'Try again';
      button.disabled = false;
    }
  });
})();
