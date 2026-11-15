import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'elsewhere.dart';

/// The line inviting the reader to email Dan.
final class ContactLine extends StatelessComponent {
  /// The contact line.
  const ContactLine({super.key});

  @override
  Component build(BuildContext context) => p([
    .text('Say hello at '),
    a(href: Elsewhere.email.href, [.text(emailAddress)]),
    .text('.'),
  ]);
}
