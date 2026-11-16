import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'logo.dart';

/// The site's logo, centred on a line of its own at the foot of a page.
final class Stamp extends StatelessComponent {
  /// The stamp.
  const Stamp({super.key});

  @override
  Component build(BuildContext context) =>
      div(classes: 'stamp', [const Logo()]);
}
