import 'dart:io';
import 'dart:math' as math;

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:test/test.dart';

/// Catppuccin Latte, the light flavour, as hex.
const Set<String> _latte = {
  '#dc8a78', '#dd7878', '#ea76cb', '#8839ef', '#d20f39', '#e64553', //
  '#fe640b', '#df8e1d', '#40a02b', '#179299', '#04a5e5', '#209fb5',
  '#1e66f5', '#7287fd', '#4c4f69', '#5c5f77', '#6c6f85', '#7c7f93',
  '#8c8fa1', '#9ca0b0', '#acb0be', '#bcc0cc', '#ccd0da', '#eff1f5',
  '#e6e9ef', '#dce0e8',
};

/// Catppuccin Mocha, the dark flavour, as hex.
const Set<String> _mocha = {
  '#f5e0dc', '#f2cdcd', '#f5c2e7', '#cba6f7', '#f38ba8', '#eba0ac', //
  '#fab387', '#f9e2af', '#a6e3a1', '#94e2d5', '#89dceb', '#74c7ec',
  '#89b4fa', '#b4befe', '#cdd6f4', '#bac2de', '#a6adc8', '#9399b2',
  '#7f849c', '#6c7086', '#585b70', '#45475a', '#313244', '#1e1e2e',
  '#181825', '#11111b',
};

/// A colour as the stylesheet writes one in a pair: hex, or `rgb()` with an
/// alpha.
const String _colour = r'#[0-9a-f]{6}|rgb\([^)]*\)';

/// Any colour written by value: hex of any length, or a colour function.
final RegExp _anyColour = RegExp(
  r'#[0-9a-f]{3,8}\b|\b(?:rgba?|hsla?|hwb|lab|lch|oklab|oklch|color)\(',
  caseSensitive: false,
);

/// A `light-dark()` pair: its light colour, then its dark.
final RegExp _pair = RegExp(
  'light-dark\\(\\s*($_colour)\\s*,\\s*($_colour)\\s*\\)',
  caseSensitive: false,
);

/// A colour's channels: [red], [green] and [blue] from 0 to 255, and its
/// [alpha] from 0 to 1.
typedef _Rgba = ({double red, double green, double blue, double alpha});

/// [colour], written as [_colour] matches one, as its channels.
_Rgba _rgba(String colour) {
  if (colour.startsWith('#')) {
    final [double red, double green, double blue] = [
      for (int at = 1; at < 7; at += 2)
        int.parse(colour.substring(at, at + 2), radix: 16).toDouble(),
    ];
    return (red: red, green: green, blue: blue, alpha: 1);
  }
  final [double red, double green, double blue, double alpha] = RegExp(
    r'\d+(?:\.\d+)?',
  ).allMatches(colour).map((RegExpMatch m) => double.parse(m[0]!)).toList();
  return (red: red, green: green, blue: blue, alpha: alpha);
}

/// [colour]'s red, green and blue as lower-case hex, its alpha dropped.
String _hex(String colour) {
  final _Rgba rgba = _rgba(colour);
  return '#${[rgba.red, rgba.green, rgba.blue].map((double c) => c.round().toRadixString(16).padLeft(2, '0')).join()}';
}

/// One of the root's colour schemes.
enum _Theme { light, dark }

/// A surface text sits on: a token's colour as its [ground], under the
/// token's colour [tint] where one lies over it.
enum _Surface {
  page('--bg'),
  band('--band'),
  alert('--band', tint: '--red-tint'),
  button('--link'),
  buttonHover('--link-hover'),
  gritTag('--bg', tint: '--grit-tint'),
  musterTag('--bg', tint: '--muster-tint'),
  optionalTag('--band', tint: '--lavender-tint');

  const _Surface(this.ground, {this.tint});

  /// The token whose colour paints the surface.
  final String ground;

  /// The token whose colour lies over [ground], if any.
  final String? tint;
}

/// A text's size, as WCAG's contrast minimum bounds it.
enum _Size {
  normal(4.5),
  large(3);

  const _Size(this.bound);

  /// The least contrast WCAG AA allows text of this size.
  final double bound;
}

/// A rule that colours text: its [selector], the token its `color` names,
/// every surface the text it matches sits [on], and that text's [size].
typedef _Text = ({
  String selector,
  String colour,
  Set<_Surface> on,
  _Size size,
});

/// Every rule in the stylesheet that colours text.
const List<_Text> _texts = [
  (
    selector: 'body',
    colour: '--text',
    on: {.page, .band, .alert},
    size: .normal,
  ),
  (selector: 'a', colour: '--link', on: {.page}, size: .normal),
  (selector: 'a:hover', colour: '--link-hover', on: {.page}, size: .normal),
  (selector: '.accent', colour: '--link', on: {.page, .band}, size: .large),
  (selector: '.wordmark', colour: '--text', on: {.page}, size: .normal),
  (
    selector: '.site-header nav a, #theme-toggle',
    colour: '--text-soft',
    on: {.page},
    size: .normal,
  ),
  (
    selector: '.site-header nav a[aria-current="page"]',
    colour: '--text',
    on: {.page},
    size: .normal,
  ),
  (
    selector: '#theme-toggle:hover',
    colour: '--link-hover',
    on: {.page},
    size: .normal,
  ),
  (selector: 'h1', colour: '--text', on: {.page}, size: .normal),
  (selector: '.lead', colour: '--text-soft', on: {.page}, size: .normal),
  (selector: '.promise li', colour: '--text-soft', on: {.band}, size: .normal),
  (selector: '.mark-always', colour: '--teal', on: {.band}, size: .large),
  (
    selector: '.mark-never',
    colour: '--never',
    on: {.page, .band},
    size: .large,
  ),
  (selector: '.tools h2', colour: '--text-muted', on: {.page}, size: .normal),
  (selector: '.tool', colour: '--text-soft', on: {.page}, size: .normal),
  (selector: '.tool h3', colour: '--name', on: {.page}, size: .normal),
  (selector: '.tool .summary', colour: '--text', on: {.page}, size: .normal),
  (
    selector: '.tag',
    colour: '--name',
    on: {.gritTag, .musterTag, .optionalTag},
    size: .normal,
  ),
  (selector: '.contact-row', colour: '--text-soft', on: {.page}, size: .normal),
  (selector: '.contact-row h2', colour: '--text', on: {.page}, size: .normal),
  (
    selector: '.panel a',
    colour: '--panel-link',
    on: {.band, .alert},
    size: .normal,
  ),
  (
    selector: '.panel a:hover',
    colour: '--link-hover',
    on: {.band, .alert},
    size: .normal,
  ),
  (
    selector: '.alert-title',
    colour: '--alert-title',
    on: {.alert},
    size: .normal,
  ),
  (
    selector: '.field input, .field textarea',
    colour: '--text',
    on: {.page},
    size: .normal,
  ),
  (selector: '.hint', colour: '--text-muted', on: {.band}, size: .normal),
  (
    selector: '#contact-send',
    colour: '--on-link',
    on: {.button, .buttonHover},
    size: .normal,
  ),
  (selector: '.sent', colour: '--text-soft', on: {.band}, size: .normal),
  (selector: '.sent h2', colour: '--text', on: {.band}, size: .normal),
  (selector: '.status', colour: '--text-muted', on: {.page}, size: .normal),
  (
    selector: '.site-footer',
    colour: '--text-footer',
    on: {.page},
    size: .normal,
  ),
  (
    selector: '.footer-note',
    colour: '--text-muted',
    on: {.page},
    size: .normal,
  ),
  (selector: '.stamp', colour: '--text-muted', on: {.page}, size: .normal),
];

/// [colour]'s relative luminance, as WCAG defines it.
double _luminance(_Rgba colour) {
  double linear(double channel) {
    final double c = channel / 255;
    return c <= 0.04045
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4) as double;
  }

  return 0.2126 * linear(colour.red) +
      0.7152 * linear(colour.green) +
      0.0722 * linear(colour.blue);
}

/// [top] composited over the opaque [bottom].
_Rgba _over(_Rgba top, _Rgba bottom) {
  double mix(double over, double under) =>
      top.alpha * over + (1 - top.alpha) * under;
  return (
    red: mix(top.red, bottom.red),
    green: mix(top.green, bottom.green),
    blue: mix(top.blue, bottom.blue),
    alpha: 1,
  );
}

/// The contrast ratio between [a] and [b], as WCAG defines it.
double _contrast(_Rgba a, _Rgba b) {
  final [double lighter, double darker] = [_luminance(a), _luminance(b)]
    ..sort((double x, double y) => y.compareTo(x));
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  final String css = File('web/site.css').readAsStringSync();

  test("every colour in the site's icon is Mocha's", () {
    final Document icon = parse(File('web/favicon.svg').readAsStringSync());
    // Its colours are presentation attributes alone, so a keyword or a
    // style cannot carry one past the check.
    expect(icon.querySelectorAll('style, [style]'), isEmpty);
    final List<String> colours = [
      for (final Element element in icon.querySelectorAll('*'))
        for (final String paint in ['fill', 'stroke'])
          if (element.attributes[paint] case final String colour
              when colour != 'none')
            colour.toLowerCase(),
    ];
    expect(colours, isNotEmpty);
    expect(colours, everyElement(isIn(_mocha)));
  });

  test('every colour token takes Latte for light and Mocha for dark', () {
    final List<RegExpMatch> pairs = _pair.allMatches(css).toList();
    expect(pairs, isNotEmpty);
    for (final RegExpMatch pair in pairs) {
      expect(_latte, contains(_hex(pair.group(1)!)), reason: pair.group(0));
      expect(_mocha, contains(_hex(pair.group(2)!)), reason: pair.group(0));
    }
  });

  test('no colour is written outside a light and dark pair', () {
    expect(
      _anyColour
          .allMatches(css.replaceAll(_pair, ''))
          .map((RegExpMatch match) => match.group(0)),
      isEmpty,
    );
  });

  group('every piece of text meets WCAG AA contrast on its surface', () {
    final String rules = css.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    final Map<String, RegExpMatch> tokens = {
      for (final RegExpMatch token in RegExp(
        '(--[\\w-]+):\\s*${_pair.pattern}',
        caseSensitive: false,
      ).allMatches(rules))
        token[1]!: token,
    };
    // A token a rule sets to another token's colour, such as a tool's name,
    // takes each colour any rule gives it.
    final Map<String, Set<String>> aliases = {};
    for (final RegExpMatch alias in RegExp(
      r'(--[\w-]+):\s*var\((--[\w-]+)\)',
    ).allMatches(rules)) {
      (aliases[alias[1]!] ??= {}).add(alias[2]!);
    }

    Iterable<_Rgba> coloursOf(String token, _Theme theme) sync* {
      if (aliases[token] case final Set<String> targets) {
        for (final String target in targets) {
          yield* coloursOf(target, theme);
        }
        return;
      }
      final RegExpMatch? pair = tokens[token];
      if (pair == null) throw StateError('No token $token in the stylesheet');
      yield _rgba(switch (theme) {
        .light => pair[2]!,
        .dark => pair[3]!,
      });
    }

    _Rgba surfaceOf(_Surface surface, _Theme theme) {
      final _Rgba ground = coloursOf(surface.ground, theme).single;
      return switch (surface.tint) {
        final String tint => _over(coloursOf(tint, theme).single, ground),
        null => ground,
      };
    }

    test('every rule that colours text is weighed', () {
      expect(
        [
          for (final RegExpMatch rule in RegExp(
            r'([^{}]+)\{([^{}]*)\}',
          ).allMatches(rules))
            for (final RegExpMatch colour in RegExp(
              r'(?<![\w-])color:\s*([^;]+);',
            ).allMatches(rule[2]!))
              (
                selector: rule[1]!.trim().replaceAll(RegExp(r'\s+'), ' '),
                colour: colour[1]!.trim(),
              ),
        ],
        unorderedEquals([
          for (final _Text text in _texts)
            (selector: text.selector, colour: 'var(${text.colour})'),
        ]),
      );
    });

    for (final _Theme theme in _Theme.values) {
      for (final _Text text in _texts) {
        test('${text.selector}, in ${theme.name}', () {
          for (final _Surface surface in text.on) {
            for (final _Rgba colour in coloursOf(text.colour, theme)) {
              expect(
                _contrast(colour, surfaceOf(surface, theme)),
                greaterThanOrEqualTo(text.size.bound),
                reason: 'on ${surface.name}',
              );
            }
          }
        });
      }
    }
  });

  test("the root's colour scheme follows the system's, unless the reader "
      'chose one', () {
    final Map<String, String> schemes = {
      for (final RegExpMatch rule in RegExp(
        r'(:root(?:\[data-theme="(?:light|dark)"\])?)\s*\{([^}]*)\}',
      ).allMatches(css))
        if (RegExp(r'color-scheme:\s*([a-z ]+);').firstMatch(rule.group(2)!)
            case final RegExpMatch scheme)
          rule.group(1)!: scheme.group(1)!.trim(),
    };
    expect(schemes, {
      ':root': 'light dark',
      ':root[data-theme="light"]': 'light',
      ':root[data-theme="dark"]': 'dark',
    });
  });
}
