import 'site_path.dart';

/// A page the build writes, at the path it is written to.
enum Page {
  /// The home page.
  home(path: SitePath('/')),

  /// The page whose form sends Dan a message.
  contact(path: SitePath('/contact')),

  /// The page saying no page stands at the reader's path.
  notFound(path: SitePath('/404.html'));

  const Page({required this.path});

  /// The path the page is written to.
  final SitePath path;

  /// The page written to [path], or [notFound] where no page is.
  static Page at(SitePath path) =>
      values.firstWhere((page) => page.path == path, orElse: () => notFound);
}
