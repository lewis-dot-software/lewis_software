import 'package:grit/grit.dart';
import 'package:lewis_software/page.dart';
import 'package:lewis_software/site_path.dart';
import 'package:test/test.dart';

void main() {
  test('every page is found at the path it is written to', () {
    for (final Page page in Page.values) {
      expect(Page.at(page.path), page);
    }
  });

  property('a path no page is written to finds the not-found page', (draw) {
    final String name = draw(
      .string(alphabet: .lettersAndDigits, minLength: 1),
      label: 'name',
    );
    expect(Page.at(SitePath('/$name')), Page.notFound);
    expect(Page.at(SitePath('/$name.html')), Page.notFound);
    expect(Page.at(SitePath('/$name/')), Page.notFound);
  });
}
