import 'package:grit/grit.dart';
import 'package:lewis_software/page.dart';
import 'package:test/test.dart';

void main() {
  test('every page is found at the path it is written to', () {
    for (final Page page in Page.values) {
      expect(Page.at(page.path), page);
    }
  });

  property('PAG-4: A path no page is written to finds the not-found page.', (
    draw,
  ) {
    final String name = draw(
      .string(alphabet: .lettersAndDigits, minLength: 1),
      label: 'name',
    );
    expect(Page.at(.new('/$name')), Page.notFound);
    expect(Page.at(.new('/$name.html')), Page.notFound);
    expect(Page.at(.new('/$name/')), Page.notFound);
  });
}
