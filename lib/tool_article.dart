import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'tool.dart';

/// A [Tool]'s entry, in the tool's own accent.
final class ToolArticle extends StatelessComponent {
  /// The entry of [tool].
  const ToolArticle(this.tool, {super.key});

  /// The tool this entry presents.
  final Tool tool;

  @override
  Component build(BuildContext context) =>
      article(classes: 'tool tool-${tool.name}', [
        h3([.text(tool.name)]),
        p(classes: 'summary', [.text(tool.summary)]),
        p([
          .text(tool.lead),
          span(classes: 'tag', [.text(tool.name)]),
          .text(tool.tail),
        ]),
        p(classes: 'links', [
          a(href: tool.source, [.text('Source')]),
          if (tool.package case final String package)
            a(href: package, [.text('pub.dev')]),
        ]),
      ]);
}
