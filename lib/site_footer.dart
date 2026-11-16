import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'elsewhere.dart';
import 'stamp.dart';
import 'tool.dart';

/// The footer of a page with words of its own: who runs the site, where its
/// work is published, what the site gathers, and the stamp.
final class SiteFooter extends StatelessComponent {
  /// The site's footer.
  const SiteFooter({super.key});

  @override
  Component build(BuildContext context) => footer(classes: 'site-footer', [
    div(classes: 'footer-lead', [
      p([
        .text(
          'lewis.software is run by Dan Lewis, who builds, tests and signs '
          'every release.',
        ),
      ]),
      p(classes: 'links', [
        a(href: Elsewhere.githubOrg.href, [.text('GitHub')]),
        if (Tool.anyOnPub)
          a(href: Elsewhere.pubPublisher.href, [.text('pub.dev')]),
      ]),
    ]),
    p(classes: 'footer-note', [
      .text('No cookies, no tracking, nothing loaded from anyone else. '),
      a(href: Elsewhere.siteSource.href, [.text("This site's source")]),
      .text('.'),
    ]),
    const Stamp(),
  ]);
}
