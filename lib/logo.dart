import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'logo_stroke.dart';

/// The site's logo, a terminal's prompt and then `ls`: a mark with no words
/// of its own, so hidden from assistive technology.
final class Logo extends StatelessComponent {
  /// The logo.
  const Logo({super.key});

  /// The logo's view box, cropped to its strokes, the `l` spanning its height.
  static const String viewBox = '3 7.4 26.6 17.2';

  @override
  Component build(BuildContext context) => svg(
    viewBox: viewBox,
    classes: 'logo',
    attributes: {'aria-hidden': 'true', 'focusable': 'false'},
    [
      for (final LogoStroke stroke in LogoStroke.values)
        path(d: stroke.path, classes: 'logo-${stroke.name}', []),
    ],
  );
}
