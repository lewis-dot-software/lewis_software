import 'package:glados/glados.dart';
import 'package:html/dom.dart';
import 'package:lewis_software/page.dart';

import 'rendered_page.dart';

/// A URL the browser fetches: [url], and [by], what fetches it, the page or
/// the site's own file that writes it.
typedef _Fetch = ({Uri url, String by});

/// The attributes through which an element has the browser fetch a URL, by
/// the element's tag.
const Map<String, List<String>> _fetchingAttributes = {
  'audio': ['src'],
  'embed': ['src'],
  'iframe': ['src'],
  'image': ['href'],
  'img': ['src', 'srcset'],
  'input': ['src'],
  'link': ['href', 'imagesrcset'],
  'object': ['data'],
  'script': ['src'],
  'source': ['src', 'srcset'],
  'track': ['src'],
  'use': ['href'],
  'video': ['src', 'poster'],
};

/// The URLs a `srcset` names, each before its descriptor.
Iterable<String> _srcsetUrls(String srcset) => srcset
    .split(',')
    .map((String candidate) => candidate.trim().split(RegExp(r'\s+')).first)
    .where((String url) => url.isNotEmpty);

/// Every URL [document]'s elements have the browser fetch, resolved against
/// [page]'s address.
List<Uri> _fetchedByElements(Document document, Page page) => [
  for (final MapEntry(key: String tag, value: List<String> attributes)
      in _fetchingAttributes.entries)
    for (final Element element in document.querySelectorAll(tag))
      for (final String attribute in attributes)
        if (element.attributes[attribute] case final String value)
          for (final String url
              in attribute.endsWith('srcset') ? _srcsetUrls(value) : [value])
            siteOrigin.resolve(page.path.value).resolve(url),
];

/// A URL written in a stylesheet, a script or an image: absolute with a
/// scheme or protocol-relative, a CSS `url()`, or a CSS `@import`'s string.
final RegExp _urlInFile = RegExp(
  r'''([a-z][a-z0-9+.-]*:)?//[^\s'"`)]+|url\(\s*['"]?([^'")\s]+)|@import\s+['"]([^'"]+)''',
  caseSensitive: false,
);

/// An XML namespace declaration, whose URI names the namespace and is never
/// fetched.
final RegExp _namespace = RegExp(
  r'''\sxmlns(:[a-z][\w.-]*)?\s*=\s*("[^"]*"|'[^']*')''',
);

/// Every URL a file the site serves at [url] writes, resolved against [url].
Iterable<Uri> _fetchedByFile(Uri url) => _urlInFile
    .allMatches(servedFile(url).readAsStringSync().replaceAll(_namespace, ''))
    .map(
      (RegExpMatch match) =>
          url.resolve(match.group(2) ?? match.group(3) ?? match.group(0)!),
    );

void main() {
  setUpAll(initialiseJaspr);

  Glados(any.choose(Page.values)).test(
    "Every page the build writes requests nothing from any host but the site's "
    'own.',
    (Page page) async {
      final List<Uri> fetched = _fetchedByElements(await rendered(page), page);
      expect(fetched, isNotEmpty, reason: 'the page loads its own files');
      // Each own file is read in turn for what it fetches, so a fetch nested
      // at any depth is checked.
      final Set<Uri> read = {};
      final List<_Fetch> queue = [
        for (final Uri url in fetched) (url: url, by: '$page'),
      ];
      while (queue.isNotEmpty) {
        final (:Uri url, :String by) = queue.removeLast();
        expect(isOwn(url), isTrue, reason: '$by fetches $url');
        if (read.add(url.removeFragment())) {
          queue.addAll([
            for (final Uri inner in _fetchedByFile(url))
              (url: inner, by: '$url'),
          ]);
        }
      }
    },
  );
}
