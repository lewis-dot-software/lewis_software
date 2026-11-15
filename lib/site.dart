import 'package:jaspr/server.dart';

import 'home_page.dart';
import 'not_found_page.dart';
import 'page.dart';
import 'site_path.dart';

/// The whole document of lewis.software at the requested path: its head and
/// its body.
final class Site extends AsyncStatelessComponent {
  /// The site's document.
  const Site({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    // The static build writes only the routes requested of it past '/', and
    // only those queued before the response to '/' returns.
    await Future.wait([
      for (final Page page in Page.values)
        ServerApp.requestRouteGeneration(page.path.value),
    ]);
    final Page page = Page.at(SitePath(Uri.parse(context.url).path));
    return Document(
      lang: 'en-GB',
      title: switch (page) {
        .home => 'lewis.software',
        .notFound => 'Page not found - lewis.software',
      },
      body: switch (page) {
        .home => const HomePage(),
        .notFound => const NotFoundPage(),
      },
    );
  }
}
