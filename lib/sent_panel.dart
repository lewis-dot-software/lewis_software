import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'page.dart';

/// The panel that takes the contact form's place once its message is sent.
///
/// It renders hidden, and focusable from script alone, so the reader is moved
/// to it as it is shown.
final class SentPanel extends StatelessComponent {
  /// The sent panel.
  const SentPanel({super.key});

  /// The panel's `id`.
  static const String id = 'contact-sent';

  /// The `id` of the panel's heading, which names it.
  static const String headingId = 'contact-sent-heading';

  @override
  Component build(BuildContext context) => section(
    id: id,
    classes: 'panel sent',
    attributes: {'hidden': '', 'tabindex': '-1', 'aria-labelledby': headingId},
    [
      h2(id: headingId, [
        .text('Message sent'),
        span(classes: 'accent', [.text('.')]),
      ]),
      p([
        .text(
          "Thanks for your message. I'll get back to you as soon as possible.",
        ),
      ]),
      p(classes: 'links', [
        a(href: Page.contact.path.value, [.text('Send another message')]),
        a(href: Page.home.path.value, [.text('Back to the home page')]),
      ]),
    ],
  );
}
