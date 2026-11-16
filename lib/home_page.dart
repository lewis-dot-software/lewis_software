import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'promise.dart';
import 'promise_column.dart';
import 'site_footer.dart';
import 'tool.dart';
import 'tool_article.dart';

/// The home page's body: what lewis.software makes, what its software
/// promises, its tools, and who runs it.
final class HomePage extends StatelessComponent {
  /// The home page.
  const HomePage({super.key});

  /// The `id` of the section listing the tools.
  static const String toolsId = 'tools';

  @override
  Component build(BuildContext context) => .fragment([
    main_([
      section(classes: 'hero', [
        h1([
          .text('Software that respects you'),
          span(classes: 'accent', [.text('.')]),
        ]),
        p(classes: 'lead', [
          .text(
            'Flutter apps and Dart developer tools, made with care and kept '
            'that way.',
          ),
        ]),
      ]),
      section(classes: 'band', [
        div(classes: 'promises', [
          for (final Promise promise in Promise.values) PromiseColumn(promise),
        ]),
      ]),
      section(id: toolsId, classes: 'tools', [
        h2([.text('Tools')]),
        div(classes: 'tool-grid', [
          for (final Tool tool in Tool.values) ToolArticle(tool),
        ]),
      ]),
    ]),
    const SiteFooter(),
  ]);
}
