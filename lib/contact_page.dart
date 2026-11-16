import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'contact_form.dart';
import 'contact_row.dart';
import 'elsewhere.dart';
import 'sent_panel.dart';
import 'site_footer.dart';

/// The contact page's body: the words on the left as ruled rows, and on the
/// right the form, or the panel that takes its place once a message is sent.
final class ContactPage extends StatelessComponent {
  /// The contact page.
  const ContactPage({super.key});

  @override
  Component build(BuildContext context) => .fragment([
    main_(classes: 'contact', [
      div(classes: 'contact-words', [
        h1([
          .text('Get in touch'),
          span(classes: 'accent', [.text('.')]),
        ]),
        p(classes: 'lead', [
          .text(
            'A question about a tool, a bug you have found, or an app you '
            'would like built. Every message is read and answered by an '
            'actual human (me, Dan 👋).',
          ),
        ]),
        div(classes: 'contact-rows', [
          const ContactRow(
            heading: 'Want an app or website built?',
            body: [
              .text(
                'Apps and websites made to order, for phones, computers and '
                'the web. Secure, thoroughly tested, respectful of the people '
                'who use them, and built to be easy to look after for years.',
              ),
            ],
          ),
          const ContactRow(
            heading: 'Email, and nothing else',
            body: [
              .text(
                'No social media, so email is the only way to get in touch.',
              ),
            ],
          ),
          ContactRow(
            heading: 'Prefer your own mail?',
            body: [
              .text('Write to '),
              a(href: Elsewhere.email.href, [.text(emailAddress)]),
              .text('.'),
            ],
          ),
        ]),
      ]),
      div(classes: 'contact-reply', [const ContactForm(), const SentPanel()]),
    ]),
    const SiteFooter(),
  ]);
}
