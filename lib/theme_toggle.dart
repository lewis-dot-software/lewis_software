import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

/// The button that switches the page between light and dark: a sun that
/// switches to light, and a moon that switches to dark, one shown at a time.
///
/// It renders hidden, with no icon chosen and a name that says what it does
/// in general, since which theme it switches to is known only in the browser.
final class ThemeToggle extends StatelessComponent {
  /// The theme toggle.
  const ThemeToggle({super.key});

  /// The toggle's `id`.
  static const String id = 'theme-toggle';

  @override
  Component build(BuildContext context) => button(
    id: id,
    type: .button,
    attributes: {'hidden': '', 'aria-label': 'Switch theme'},
    [
      svg(
        viewBox: '0 0 24 24',
        classes: 'theme-icon icon-light',
        attributes: {'aria-hidden': 'true', 'focusable': 'false'},
        [
          circle(cx: '12', cy: '12', r: '4', []),
          for (final (String x1, String y1, String x2, String y2) in _rays)
            line(x1: x1, y1: y1, x2: x2, y2: y2, []),
        ],
      ),
      svg(
        viewBox: '0 0 24 24',
        classes: 'theme-icon icon-dark',
        attributes: {'aria-hidden': 'true', 'focusable': 'false'},
        [path(d: 'M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z', [])],
      ),
    ],
  );

  /// The sun's eight rays, each from its inner end to its outer.
  static const List<(String, String, String, String)> _rays = [
    ('12', '2.5', '12', '4.5'),
    ('12', '19.5', '12', '21.5'),
    ('2.5', '12', '4.5', '12'),
    ('19.5', '12', '21.5', '12'),
    ('5.3', '5.3', '6.7', '6.7'),
    ('17.3', '17.3', '18.7', '18.7'),
    ('5.3', '18.7', '6.7', '17.3'),
    ('17.3', '6.7', '18.7', '5.3'),
  ];
}
