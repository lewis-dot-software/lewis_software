// lewis.software's theme toggle. The page follows the reader's system theme,
// and a choice made here overrides it, kept in this browser's own storage and
// never sent anywhere. It runs before the body is parsed, so a kept choice
// applies before the first paint.
(() => {
  const root = document.documentElement;
  const key = 'theme';
  const system = window.matchMedia('(prefers-color-scheme: dark)');

  const systemTheme = () => (system.matches ? 'dark' : 'light');
  const currentTheme = () => root.dataset.theme ?? systemTheme();

  // Storage refused, as a private window or a blocked site refuses it with a
  // DOMException, leaves the toggle working for this page alone, which is all
  // it can do without storage. Any other error is a bug, and is thrown.
  const refused = (error) => {
    if (!(error instanceof DOMException)) throw error;
  };
  const kept = () => {
    try {
      return localStorage.getItem(key);
    } catch (error) {
      refused(error);
      return null;
    }
  };
  const keep = (theme) => {
    try {
      if (theme === null) {
        localStorage.removeItem(key);
      } else {
        localStorage.setItem(key, theme);
      }
    } catch (error) {
      refused(error);
    }
  };

  // A choice that matches the system's is no override, so the page goes back
  // to following the system, and forgets the choice.
  const choose = (theme) => {
    const override =
      (theme === 'light' || theme === 'dark') && theme !== systemTheme()
        ? theme
        : null;
    if (override === null) {
      delete root.dataset.theme;
    } else {
      root.dataset.theme = override;
    }
    keep(override);
  };

  choose(kept());

  document.addEventListener('DOMContentLoaded', () => {
    const toggle = document.getElementById('theme-toggle');
    const label = () => {
      const next = currentTheme() === 'dark' ? 'light' : 'dark';
      toggle.dataset.next = next;
      toggle.setAttribute('aria-label', `Switch to the ${next} theme`);
    };

    toggle.addEventListener('click', () => {
      choose(currentTheme() === 'dark' ? 'light' : 'dark');
      label();
    });
    system.addEventListener('change', () => {
      choose(root.dataset.theme ?? null);
      label();
    });

    label();
    toggle.hidden = false;
  });
})();
