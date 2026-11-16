import 'package:html/dom.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:lewis_software/contact_field.dart';
import 'package:lewis_software/contact_form.dart';
import 'package:lewis_software/elsewhere.dart';
import 'package:lewis_software/home_page.dart';
import 'package:lewis_software/logo.dart';
import 'package:lewis_software/logo_stroke.dart';
import 'package:lewis_software/page.dart';
import 'package:lewis_software/sent_panel.dart';
import 'package:lewis_software/site.dart';
import 'package:lewis_software/theme_toggle.dart';
import 'package:lewis_software/tool.dart';
import 'package:lewis_software/topic.dart';

import 'rendered_page.dart';

/// Every `href` the links in [element] lead to, in document order.
List<String> _hrefs(Element element) => [
  for (final Element link in element.querySelectorAll('a[href]'))
    link.attributes['href']!,
];

/// The text of each heading, paragraph and list item in [document], in
/// document order, a row of links apart, its whitespace collapsed as a
/// browser collapses it.
List<String> _words(Document document) => [
  for (final Element element in document.querySelectorAll('h1, h2, h3, p, li'))
    if (!element.classes.contains('links'))
      element.text.trim().replaceAll(RegExp(r'\s+'), ' '),
];

void main() {
  setUpAll(initialiseJaspr);

  testServer(
    'the site renders a British English home page titled lewis.software',
    (tester) async {
      tester.pumpComponent(const Site());
      final DocumentResponse response = await tester.request('/');
      expect(response.statusCode, 200);
      expect(response.document?.documentElement?.attributes['lang'], 'en-GB');
      expect(response.document?.querySelector('title')?.text, 'lewis.software');
      expect(
        response.document?.querySelector('main h1')?.text,
        'Software that respects you.',
      );
    },
  );

  test('the home page links the org, the publisher and each tool', () async {
    final Document home = await rendered(.home);
    final Element footerLead = home.querySelector('footer .footer-lead')!;
    expect(_hrefs(footerLead), [
      Elsewhere.githubOrg.href,
      Elsewhere.pubPublisher.href,
    ]);
    expect(_hrefs(home.querySelector('main #${HomePage.toolsId}')!), [
      for (final Tool tool in Tool.values) ...[tool.source, tool.package],
    ]);
  });

  for (final String path in ['/404.html', '/no/such/page']) {
    testServer('the site renders the not-found page at $path', (tester) async {
      tester.pumpComponent(const Site());
      final DocumentResponse response = await tester.request(path);
      expect(response.document?.documentElement?.attributes['lang'], 'en-GB');
      expect(
        response.document?.querySelector('title')?.text,
        'Page not found - lewis.software',
      );
      expect(
        response.document?.querySelector('main h1')?.text,
        'Nothing lives here.',
      );
      expect(
        response.document?.querySelector('main a')?.attributes['href'],
        Page.home.path.value,
      );
    });
  }

  test("the home page's words are candidate D's, in order", () async {
    expect(_words(await rendered(.home)), [
      'Software that respects you.',
      'Flutter apps and Dart developer tools, made with care and kept that '
          'way.',
      '+Always',
      'Says plainly what it does, and what it does with your data.',
      'Works offline, with no account, wherever it can.',
      'Is tested well past what it strictly needs.',
      '−Never',
      'Tricks you with dark patterns to keep you hooked or paying.',
      'Ships AI-written code without thorough human review.',
      'Sells your data, or collects more than it needs to work. Any crash '
          'reports and analytics are anonymous.',
      'Tools',
      'grit',
      'Property-based testing for Dart.',
      'Say what should hold for every input. grit finds an input that breaks '
          'it, then shrinks it to the smallest case that still fails, so the '
          'bug is plain to see. Its shrinker is checked against a model proved '
          'in Lean.',
      'muster',
      'Real codebases to test your Dart tools against.',
      'Pin the projects your tool gets tested against, and muster brings each '
          'one to that commit, resolved and ready to read. Your tool is then '
          'tested on real code people wrote, and every run sees exactly the '
          'same code.',
      'lewis.software is run by Dan Lewis, who builds, tests and signs every '
          'release.',
      "No cookies, no tracking, nothing loaded from anyone else. This site's "
          'source.',
    ]);
  });

  test("the not-found page's words are candidate D's, in order", () async {
    expect(_words(await rendered(.notFound)), [
      '−404',
      'Nothing lives here.',
      "The page you were after isn't on lewis.software. It may have moved, or "
          'the link may have a typo.',
      'Back to the home page',
    ]);
  });

  testServer('the site renders the contact page at /contact', (tester) async {
    tester.pumpComponent(const Site());
    final DocumentResponse response = await tester.request('/contact');
    expect(response.statusCode, 200);
    expect(response.document?.documentElement?.attributes['lang'], 'en-GB');
    expect(
      response.document?.querySelector('title')?.text,
      'Contact - lewis.software',
    );
    expect(response.document?.querySelector('main h1')?.text, 'Get in touch.');
  });

  test("the contact page's words are candidate B's, in order", () async {
    expect(_words(await rendered(.contact)), [
      'Get in touch.',
      'A question about a tool, a bug you have found, or an app you would '
          'like built. Every message is read and answered by an actual human '
          '(me, Dan 👋).',
      'Want an app or website built?',
      'Apps and websites made to order, for phones, computers and the web. '
          'Secure, thoroughly tested, respectful of the people who use them, '
          'and built to be easy to look after for years.',
      'Email, and nothing else',
      'No social media, so email is the only way to get in touch.',
      'Prefer your own mail?',
      'Write to dan@lewis.software.',
      'Your message did not send.',
      'Everything you wrote is still here. Try again in a moment, or write to '
          'dan@lewis.software.',
      'Your name and email are for the reply, nothing else.',
      'Sent by email, with nothing kept on this site.',
      'Message sent.',
      "Thanks for your message. I'll get back to you as soon as possible.",
      'lewis.software is run by Dan Lewis, who builds, tests and signs every '
          'release.',
      "No cookies, no tracking, nothing loaded from anyone else. This site's "
          'source.',
    ]);
  });

  test("the contact form's controls are candidate B's, in order", () async {
    final Element form = (await rendered(.contact))
        .getElementById(ContactForm.id)!;
    expect(
      form.querySelector('legend')!.text.replaceAll(RegExp(r'\s+'), ' '),
      'What is it about? Optional',
    );
    expect(
      [
        for (final Element chip in form.querySelectorAll('label.chip'))
          chip.text.trim(),
      ],
      [
        'An existing tool or app',
        'An app or website built for you',
        'Anything else',
      ],
    );
    expect(
      [
        for (final Element label in form.querySelectorAll('.field label'))
          label.text,
      ],
      ['Name', 'Email', 'Message'],
    );
    expect(form.querySelector('button[type="submit"]')!.text, 'Send message');
  });

  test('the contact form posts to the contact page, and works with no '
      'script', () async {
    final Document contact = await rendered(.contact);
    final Element form = contact.getElementById(ContactForm.id)!;
    expect(form.localName, 'form');
    expect(form.attributes['action'], Page.contact.path.value);
    expect(form.attributes['method'], 'post');
    expect(form.attributes, isNot(contains('novalidate')));
    // The alert and the panel wait on a send, so the form stands alone.
    expect(
      contact.getElementById(ContactForm.failedId)!.attributes,
      containsPair('hidden', ''),
    );
    expect(
      contact.getElementById(SentPanel.id)!.attributes,
      containsPair('hidden', ''),
    );
    expect(
      contact.getElementById(ContactForm.failedId)!.attributes['role'],
      'alert',
    );
  });

  test('every field is required, labelled, and checked by the browser '
      'itself', () async {
    final Element form = (await rendered(.contact))
        .getElementById(ContactForm.id)!;
    for (final ContactField field in ContactField.values) {
      final Element control = form.querySelector('[name="${field.name}"]')!;
      expect(control.id, field.id, reason: field.name);
      expect(control.attributes, contains('required'), reason: field.name);
      expect(
        control.attributes['maxlength'],
        '${field.maxLength}',
        reason: field.name,
      );
      expect(
        form.querySelector('label[for="${field.id}"]')?.text,
        field.label,
        reason: field.name,
      );
    }
    expect(
      form.querySelector('[name="${ContactField.email.name}"]')!.attributes,
      containsPair('type', 'email'),
    );
    expect(
      form.querySelector('[name="${ContactField.message.name}"]')!.localName,
      'textarea',
    );
  });

  test('the topic is optional, one of its chips at most, each sending its '
      'words', () async {
    final List<Element> radios = (await rendered(.contact))
        .querySelectorAll('input[name="${Topic.fieldName}"]');
    expect(
      [
        for (final Element radio in radios)
          (radio.attributes['type'], radio.attributes['value']),
      ],
      [for (final Topic topic in Topic.values) ('radio', topic.label)],
    );
    expect(
      radios.where((radio) => radio.attributes.containsKey('required')),
      isEmpty,
    );
  });

  test("the contact page offers Dan's address as the way round the form, "
      'and the sent panel the way on', () async {
    final Document contact = await rendered(.contact);
    expect(_hrefs(contact.querySelector('main .contact-row:last-child')!), [
      Elsewhere.email.href,
    ]);
    expect(_hrefs(contact.getElementById(ContactForm.failedId)!), [
      Elsewhere.email.href,
    ]);
    expect(_hrefs(contact.getElementById(SentPanel.id)!), [
      Page.contact.path.value,
      Page.home.path.value,
    ]);
  });

  for (final Page page in Page.values) {
    test('the $page page carries no inline script or style', () async {
      final Document document = await rendered(page);
      expect(document.querySelectorAll('style'), isEmpty);
      expect(document.querySelectorAll('[style]'), isEmpty);
      expect(document.querySelectorAll('script:not([src])'), isEmpty);
      for (final Element element in document.querySelectorAll('*')) {
        expect(
          element.attributes.keys.whereType<String>().where(
            (String name) => name.startsWith('on'),
          ),
          isEmpty,
          reason: '<${element.localName}> carries an event handler',
        );
      }
    });

    test('the $page page takes its look and its theme toggle from the '
        "site's own files", () async {
      final Document document = await rendered(page);
      final List<String> styles = [
        for (final Element link in document.querySelectorAll(
          'link[rel="stylesheet"]',
        ))
          link.attributes['href']!,
      ];
      final List<String> scripts = [
        for (final Element script in document.querySelectorAll('script[src]'))
          script.attributes['src']!,
      ];
      expect(styles, ['/site.css']);
      expect(scripts, ['/theme.js', if (page == .contact) '/contact.js']);
      for (final String file in [...styles, ...scripts]) {
        expect(servedFile(siteOrigin.resolve(file)).existsSync(), isTrue);
      }
      expect(
        document.querySelector('header #${ThemeToggle.id}')?.attributes,
        containsPair('hidden', ''),
      );
    });

    test("the $page page names the site's own icon", () async {
      final List<Element> icons = (await rendered(page))
          .querySelectorAll('link[rel="icon"]');
      expect(
        [for (final Element icon in icons) icon.attributes['href']],
        ['/favicon.svg'],
      );
      expect(icons.single.attributes['type'], 'image/svg+xml');
      expect(
        servedFile(siteOrigin.resolve('/favicon.svg')).existsSync(),
        isTrue,
      );
    });

    test(
      "the $page page's header leads with the ls logo, hidden from "
      'assistive technology, inside the wordmark that names the site',
      () async {
        final Element wordmark = (await rendered(page))
            .querySelector('header a.wordmark')!;
        expect(wordmark.children.last.text, 'lewis.software');
        final Element logo = wordmark.children.first;
        expect(logo.localName, 'svg');
        expect(logo.attributes, containsPair('aria-hidden', 'true'));
        expect(
          logo.attributes['viewbox'] ?? logo.attributes['viewBox'],
          Logo.viewBox,
        );
        expect(
          [
            for (final Element stroke in logo.querySelectorAll('path'))
              (stroke.className, stroke.attributes['d']),
          ],
          [
            for (final LogoStroke stroke in LogoStroke.values)
              ('logo-${stroke.name}', stroke.path),
          ],
        );
      },
    );

    test(
      "the $page page's footer ends on the logo, centred as a stamp",
      () async {
        final Element footer = (await rendered(page)).querySelector('footer')!;
        final Element stamp = footer.children.last;
        expect(stamp.className, 'stamp');
        expect(stamp.children.map((Element child) => child.className), [
          'logo',
        ]);
      },
    );

    test("the $page page's header leads to the contact page, marked as "
        'current there alone', () async {
      final Element nav = (await rendered(page)).querySelector('header nav')!;
      final Element contact = nav
          .querySelectorAll('a')
          .singleWhere((Element link) => link.text == 'Contact');
      expect(contact.attributes['href'], Page.contact.path.value);
      expect(
        [
          for (final Element link in nav.querySelectorAll('[aria-current]'))
            (link.text, link.attributes['aria-current']),
        ],
        [if (page == .contact) ('Contact', 'page')],
      );
    });

    test(
      "the $page page's footer carries no contact line of its own",
      () async {
        final Element footer = (await rendered(page)).querySelector('footer')!;
        expect(footer.text, isNot(contains(emailAddress)));
        expect(footer.querySelectorAll('a[href^="mailto:"]'), isEmpty);
      },
    );

    test("the $page page's theme toggle is a sun and a moon, named for "
        'assistive technology', () async {
      final Element toggle = (await rendered(page))
          .querySelector('header button#${ThemeToggle.id}')!;
      expect(toggle.attributes['aria-label'], isNotEmpty);
      expect(toggle.text.trim(), isEmpty);
      expect(
        [
          for (final Element icon in toggle.querySelectorAll('svg'))
            (icon.className, icon.attributes['aria-hidden']),
        ],
        [('theme-icon icon-light', 'true'), ('theme-icon icon-dark', 'true')],
      );
    });
  }
}
