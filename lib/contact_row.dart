import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

/// One ruled row of the contact page's words: a heading, then what it says.
final class ContactRow extends StatelessComponent {
  /// The row headed [heading], saying [body].
  const ContactRow({required this.heading, required this.body, super.key});

  /// The row's heading.
  final String heading;

  /// The row's words, which may hold a link.
  final List<Component> body;

  @override
  Component build(BuildContext context) => div(classes: 'contact-row', [
    h2([.text(heading)]),
    p(body),
  ]);
}
