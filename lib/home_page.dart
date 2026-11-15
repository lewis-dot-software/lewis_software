import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

/// The home page's body.
final class HomePage extends StatelessComponent {
  /// The home page.
  const HomePage({super.key});

  @override
  Component build(BuildContext context) => main_([
    h1([.text('lewis.software')]),
    p([.text('A placeholder, served while the home page is built.')]),
  ]);
}
