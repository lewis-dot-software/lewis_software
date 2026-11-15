import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'elsewhere.dart';
import 'home_page.dart';
import 'page.dart';
import 'theme_toggle.dart';

/// The site's header: the wordmark, then the sections' links and the theme
/// toggle.
final class SiteHeader extends StatelessComponent {
  /// The site's header.
  const SiteHeader({super.key});

  @override
  Component build(BuildContext context) => header(classes: 'site-header', [
    a(href: Page.home.path.value, classes: 'wordmark', [
      .text('lewis'),
      span(classes: 'accent', [.text('.')]),
      .text('software'),
    ]),
    nav(
      attributes: {'aria-label': 'Sections'},
      [
        a(href: '${Page.home.path.value}#${HomePage.toolsId}', [
          .text('Tools'),
        ]),
        a(href: Elsewhere.email.href, [.text('Contact')]),
        const ThemeToggle(),
      ],
    ),
  ]);
}
