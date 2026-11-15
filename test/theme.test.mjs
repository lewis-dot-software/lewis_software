// web/theme.js, run against a fake browser: a root element, a toggle, the
// system's colour scheme and the browser's storage, each driven by the test.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import vm from 'node:vm';

const script = readFileSync(new URL('../web/theme.js', import.meta.url), 'utf8');

// A store that keeps what it is given, as `localStorage` does.
const keepingStorage = (initial = {}) => {
  const items = new Map(Object.entries(initial));
  return {
    getItem: (key) => items.get(key) ?? null,
    setItem: (key, value) => items.set(key, String(value)),
    removeItem: (key) => items.delete(key),
  };
};

// A store that refuses every call with [error], as a blocked site's does.
const refusingStorage = (error) => {
  const refuse = () => {
    throw error;
  };
  return { getItem: refuse, setItem: refuse, removeItem: refuse };
};

// Runs theme.js in a fake browser whose system is [dark] and whose storage
// is [storage], and returns the handles a test drives it by.
const browser = ({ dark, storage }) => {
  const listeners = { ready: [], click: [], change: [] };
  const toggle = {
    hidden: true,
    dataset: {},
    attributes: {},
    setAttribute(name, value) {
      this.attributes[name] = value;
    },
    addEventListener: (type, listener) => listeners[type].push(listener),
  };
  const root = { dataset: {} };
  const system = {
    matches: dark,
    addEventListener: (type, listener) => listeners[type].push(listener),
  };
  vm.runInNewContext(script, {
    DOMException,
    localStorage: storage,
    window: { matchMedia: () => system },
    document: {
      documentElement: root,
      getElementById: (id) => (id === 'theme-toggle' ? toggle : null),
      addEventListener: (type, listener) => {
        assert.equal(type, 'DOMContentLoaded');
        listeners.ready.push(listener);
      },
    },
  });
  return {
    root,
    toggle,
    ready: () => listeners.ready.forEach((listener) => listener()),
    press: () => listeners.click.forEach((listener) => listener()),
    turnSystem: (toDark) => {
      system.matches = toDark;
      listeners.change.forEach((listener) => listener());
    },
  };
};

test('with nothing kept, the page follows the system and offers the other theme', () => {
  const page = browser({ dark: true, storage: keepingStorage() });
  page.ready();
  assert.equal(page.root.dataset.theme, undefined);
  assert.equal(page.toggle.hidden, false);
  assert.equal(page.toggle.dataset.next, 'light');
  assert.equal(page.toggle.attributes['aria-label'], 'Switch to the light theme');
});

test('a kept choice applies before the body is parsed', () => {
  const page = browser({ dark: true, storage: keepingStorage({ theme: 'light' }) });
  assert.equal(page.root.dataset.theme, 'light');
});

test('a press overrides the system, and is kept', () => {
  const storage = keepingStorage();
  const page = browser({ dark: true, storage });
  page.ready();
  page.press();
  assert.equal(page.root.dataset.theme, 'light');
  assert.equal(storage.getItem('theme'), 'light');
  assert.equal(page.toggle.dataset.next, 'dark');
});

test('pressed back, the page follows the system and forgets the choice', () => {
  const storage = keepingStorage();
  const page = browser({ dark: true, storage });
  page.ready();
  page.press();
  page.press();
  assert.equal(page.root.dataset.theme, undefined);
  assert.equal(storage.getItem('theme'), null);
  assert.equal(page.toggle.dataset.next, 'light');
});

test('a system that comes to match the choice clears it', () => {
  const storage = keepingStorage();
  const page = browser({ dark: false, storage });
  page.ready();
  page.press();
  assert.equal(storage.getItem('theme'), 'dark');
  page.turnSystem(true);
  assert.equal(page.root.dataset.theme, undefined);
  assert.equal(storage.getItem('theme'), null);
  page.turnSystem(false);
  assert.equal(page.root.dataset.theme, undefined);
  assert.equal(page.toggle.dataset.next, 'dark');
});

test('a kept choice that matches the system is forgotten on load', () => {
  const storage = keepingStorage({ theme: 'dark' });
  const page = browser({ dark: true, storage });
  assert.equal(page.root.dataset.theme, undefined);
  assert.equal(storage.getItem('theme'), null);
});

test('storage refused leaves the toggle working for the page alone', () => {
  const page = browser({
    dark: true,
    storage: refusingStorage(new DOMException('blocked', 'SecurityError')),
  });
  page.ready();
  page.press();
  assert.equal(page.root.dataset.theme, 'light');
  assert.equal(page.toggle.dataset.next, 'dark');
});

test('a storage failure that is not a refusal is thrown', () => {
  assert.throws(
    () => browser({ dark: true, storage: refusingStorage(new TypeError('bug')) }),
    TypeError,
  );
});
