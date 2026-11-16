import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

/// A ray of the sun: a line from ([x1], [y1]), its inner end, to ([x2],
/// [y2]), its outer, in the icon's 24 by 24 view box.
typedef _Ray = ({String x1, String y1, String x2, String y2});

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
          for (final _Ray ray in _rays)
            line(x1: ray.x1, y1: ray.y1, x2: ray.x2, y2: ray.y2, []),
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

  /// The sun's eight rays.
  static const List<_Ray> _rays = [
    (x1: '12', y1: '2.5', x2: '12', y2: '4.5'),
    (x1: '12', y1: '19.5', x2: '12', y2: '21.5'),
    (x1: '2.5', y1: '12', x2: '4.5', y2: '12'),
    (x1: '19.5', y1: '12', x2: '21.5', y2: '12'),
    (x1: '5.3', y1: '5.3', x2: '6.7', y2: '6.7'),
    (x1: '17.3', y1: '17.3', x2: '18.7', y2: '18.7'),
    (x1: '5.3', y1: '18.7', x2: '6.7', y2: '17.3'),
    (x1: '17.3', y1: '6.7', x2: '18.7', y2: '5.3'),
  ];
}
