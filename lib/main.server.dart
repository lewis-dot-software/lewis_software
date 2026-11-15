/// Renders lewis.software to static HTML.
library;

import 'package:jaspr/server.dart';

import 'main.server.options.dart';
import 'site.dart';

/// Initialises Jaspr's server options and renders the [Site].
void main() {
  Jaspr.initializeApp(options: defaultServerOptions);
  runApp(const Site());
}
