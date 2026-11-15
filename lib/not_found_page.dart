import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

/// The body of the page saying no page stands at the reader's path.
final class NotFoundPage extends StatelessComponent {
  /// The not-found page.
  const NotFoundPage({super.key});

  @override
  Component build(BuildContext context) => main_([
    h1([.text('Page not found')]),
    p([.text('Nothing stands at this address.')]),
    p([
      a(href: '/', [.text('Back to the home page')]),
    ]),
  ]);
}
