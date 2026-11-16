import 'dart:io';

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

/// [colour]'s red, green and blue as lower-case hex, its alpha dropped.
String _hex(String colour) {
  if (colour.startsWith('#')) return colour.toLowerCase();
  final List<int> channels = RegExp(r'\d+(?:\.\d+)?')
      .allMatches(colour)
      .take(3)
      .map((RegExpMatch match) => int.parse(match.group(0)!))
      .toList();
  return '#${channels.map((int c) => c.toRadixString(16).padLeft(2, '0')).join()}';
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
