import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'elsewhere.dart';
import 'field_control.dart';
import 'page.dart';
import 'topic.dart';
import 'topic_chip.dart';

/// The form that sends Dan a message, posted to the contact page's own path,
/// where the site's Worker answers it.
///
/// It renders ready to fill in, its alert hidden. The alert is shown, and the
/// button reads "Try again", once a send has failed.
final class ContactForm extends StatelessComponent {
  /// The contact form.
  const ContactForm({super.key});

  /// The form's `id`.
  static const String id = 'contact-form';

  /// The `id` of the alert a failed send shows.
  static const String failedId = 'contact-failed';

  /// The `id` of the button that sends the message.
  static const String sendId = 'contact-send';

  /// The `id` of the hint on what the name and email are for.
  static const String hintId = 'contact-hint';

  @override
  Component build(BuildContext context) => form(
    id: id,
    action: Page.contact.path.value,
    method: .post,
    classes: 'panel contact-form',
    [
      div(
        id: failedId,
        classes: 'alert',
        attributes: {'role': 'alert', 'hidden': ''},
        [
          p(classes: 'alert-title', [.text('Your message did not send.')]),
          p([
            .text(
              'Everything you wrote is still here. Try again in a moment, or '
              'write to ',
            ),
            a(href: Elsewhere.email.href, [.text(emailAddress)]),
            .text('.'),
          ]),
        ],
      ),
      fieldset(classes: 'topics', [
        legend([
          .text('${Topic.legend} '),
          span(classes: 'tag tag-optional', [.text('Optional')]),
        ]),
        div(classes: 'chips', [
          for (final Topic topic in Topic.values) TopicChip(topic),
        ]),
      ]),
      div(classes: 'pair', [
        const FieldControl(.name, describedBy: hintId),
        const FieldControl(.email, describedBy: hintId),
      ]),
      p(id: hintId, classes: 'hint', [
        .text('Your name and email are for the reply, nothing else.'),
      ]),
      const FieldControl(.message),
      div(classes: 'send', [
        button(id: sendId, type: .submit, [.text('Send message')]),
        p(classes: 'hint', [
          .text('Sent by email, with nothing kept on this site.'),
        ]),
      ]),
    ],
  );
}
