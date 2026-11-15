import 'dart:convert';
import 'dart:io';

import 'package:lewis_software/page.dart';
import 'package:test/test.dart';

void main() {
  test('the Worker answers a path with no page with the not-found page and '
      'its 404 status', () {
    // wrangler.jsonc holds no comment, so it parses as JSON.
    final Object? config = jsonDecode(
      File('wrangler.jsonc').readAsStringSync(),
    );
    expect(config, isA<Map<String, Object?>>());
    final Object? assets = (config! as Map<String, Object?>)['assets'];
    expect(assets, containsPair('directory', 'build/jaspr'));
    // `404-page` serves the nearest `404.html` with a 404 status.
    expect(assets, containsPair('not_found_handling', '404-page'));
    expect(Page.notFound.path.value, '/404.html');
  });
}
