import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

/// The whole document of lewis.software: its head and its body.
final class Site extends StatelessComponent {
  /// The site's document.
  const Site({super.key});

  @override
  Component build(BuildContext context) => const Document(
    lang: 'en-GB',
    title: 'lewis.software',
    body: main_([
      h1([.text('lewis.software')]),
    ]),
  );
}
