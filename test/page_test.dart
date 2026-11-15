import 'package:glados/glados.dart';
import 'package:lewis_software/page.dart';
import 'package:lewis_software/site_path.dart';

void main() {
  test('every page is found at the path it is written to', () {
    for (final Page page in Page.values) {
      expect(Page.at(page.path), page);
    }
  });

  Glados(any.nonEmptyLetterOrDigits).test(
    'a path no page is written to finds the not-found page',
    (String name) {
      expect(Page.at(SitePath('/$name')), Page.notFound);
      expect(Page.at(SitePath('/$name.html')), Page.notFound);
      expect(Page.at(SitePath('/$name/')), Page.notFound);
    },
  );
}
