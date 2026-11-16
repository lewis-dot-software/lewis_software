import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'contact_line.dart';
import 'mark.dart';
import 'page.dart';
import 'stamp.dart';

/// The body of the page saying no page stands at the reader's path.
final class NotFoundPage extends StatelessComponent {
  /// The not-found page.
  const NotFoundPage({super.key});

  @override
  Component build(BuildContext context) => .fragment([
    main_(classes: 'not-found', [
      p(classes: 'status', [const Mark(.never), .text('404')]),
      h1([
        .text('Nothing lives here'),
        span(classes: 'accent', [.text('.')]),
      ]),
      p(classes: 'lead', [
        .text(
          "The page you were after isn't on lewis.software. It may have "
          'moved, or the link may have a typo.',
        ),
      ]),
      p(classes: 'back', [
        a(href: Page.home.path.value, [.text('Back to the home page')]),
      ]),
    ]),
    footer(classes: 'site-footer', [const ContactLine(), const Stamp()]),
  ]);
}
