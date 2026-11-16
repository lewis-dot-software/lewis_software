import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'home_page.dart';
import 'logo.dart';
import 'page.dart';
import 'theme_toggle.dart';

/// The site's header: the wordmark led by the logo, then the sections' links
/// and the theme toggle.
final class SiteHeader extends StatelessComponent {
  /// The header of [current].
  const SiteHeader(this.current, {super.key});

  /// The page the header stands on, whose own link is marked as current.
  final Page current;

  @override
  Component build(BuildContext context) => header(classes: 'site-header', [
    a(href: Page.home.path.value, classes: 'wordmark', [
      const Logo(),
      // Its own element, so the name stays one run of text however the
      // build lays out the link's markup.
      span([
        .text('lewis'),
        span(classes: 'accent', [.text('.')]),
        .text('software'),
      ]),
    ]),
    nav(
      attributes: {'aria-label': 'Sections'},
      [
        a(href: '${Page.home.path.value}#${HomePage.toolsId}', [
          .text('Tools'),
        ]),
        a(
          href: Page.contact.path.value,
          attributes: {if (current == .contact) 'aria-current': 'page'},
          [.text('Contact')],
        ),
        const ThemeToggle(),
      ],
    ),
  ]);
}
