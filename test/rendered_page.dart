import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:jaspr/server.dart' hide Document;
import 'package:lewis_software/main.server.options.dart';
import 'package:lewis_software/page.dart';
import 'package:lewis_software/site.dart';

/// The origin the site is served from.
final Uri siteOrigin = .parse('https://lewis.software');

/// Whether [url] is on the site's own origin.
bool isOwn(Uri url) =>
    url.scheme == siteOrigin.scheme && url.host == siteOrigin.host;

/// Readies Jaspr to render, once before a file's tests.
void initialiseJaspr() => Jaspr.initializeApp(options: defaultServerOptions);

/// The document the build writes for [page].
Future<Document> rendered(Page page) async {
  final ResponseLike response = await renderComponent(
    const Site(),
    request: .new('GET', siteOrigin.resolve(page.path.value)),
  );
  return parse(utf8.decode(response.body));
}

/// The file in `web/` the build serves at [url], one of the site's own.
File servedFile(Uri url) => .new('web${url.path}');
