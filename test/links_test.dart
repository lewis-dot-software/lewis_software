import 'package:glados/glados.dart';
import 'package:html/dom.dart';
import 'package:lewis_software/elsewhere.dart';
import 'package:lewis_software/page.dart';
import 'package:lewis_software/site_path.dart';
import 'package:lewis_software/tool.dart';

import 'rendered_page.dart';

void main() {
  setUpAll(initialiseJaspr);

  final Set<SitePath> written = {
    for (final Page page in Page.values) page.path,
  };

  Glados(any.choose(Page.values)).test(
    "Every link between the site's pages leads to a page the build wrote.",
    (Page page) async {
      final Uri address = siteOrigin.resolve(page.path.value);
      final Document document = await rendered(page);
      final List<Uri> links = [
        for (final Element link in document.querySelectorAll('a[href]'))
          address.resolve(link.attributes['href']!),
      ];
      expect(links.where(isOwn), isNotEmpty, reason: '$page links the site');
      for (final Uri link in links.where(isOwn)) {
        final SitePath target = SitePath(link.path);
        expect(written, contains(target), reason: '$page links $link');
        if (link.fragment.isNotEmpty) {
          final Document landing = await rendered(Page.at(target));
          expect(
            landing.getElementById(link.fragment),
            isNotNull,
            reason: '$page links $link, whose page has no such id',
          );
        }
      }
    },
  );

  final Set<String> published = {
    for (final Tool tool in Tool.values) ?tool.package,
    if (Tool.anyOnPub) Elsewhere.pubPublisher.href,
  };

  Glados(any.choose(Page.values)).test(
    "Every pub.dev link a page shows is a published tool's package, or the "
    'publisher while a tool is published.',
    (Page page) async {
      final Document document = await rendered(page);
      for (final Element link in document.querySelectorAll('a[href]')) {
        final String href = link.attributes['href']!;
        if (Uri.parse(href).host == 'pub.dev') {
          expect(published, contains(href), reason: '$page links $href');
        }
      }
    },
  );
}
