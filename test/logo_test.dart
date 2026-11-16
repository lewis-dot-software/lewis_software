import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:lewis_software/logo_stroke.dart';
import 'package:test/test.dart';

void main() {
  test("the favicon draws the header's logo, stroke for stroke, on a Mocha "
      'square', () {
    final Document favicon = parse(File('web/favicon.svg').readAsStringSync());
    final Element svg = favicon.querySelector('svg')!;
    expect(svg.attributes['viewBox'], '0 0 32 32');
    final Element square = svg.children.first;
    expect(square.localName, 'rect');
    expect(square.attributes, containsPair('width', '32'));
    expect(square.attributes, containsPair('height', '32'));
    // Mocha's base, so the mark reads on a light tab and a dark one.
    expect(square.attributes, containsPair('fill', '#1e1e2e'));
    expect(
      [
        for (final Element stroke in favicon.querySelectorAll('path'))
          stroke.attributes['d'],
      ],
      [for (final LogoStroke stroke in LogoStroke.values) stroke.path],
    );
  });
}
