import 'elsewhere.dart';
import 'publication.dart';

/// A developer tool lewis.software publishes, named by [name].
enum Tool {
  /// The property-based testing package.
  grit(
    summary: 'Property-based testing for Dart.',
    lead: 'Say what should hold for every input. ',
    tail:
        ' finds an input that breaks it, then shrinks it to the smallest case '
        'that still fails, so the bug is plain to see. Its shrinker is checked '
        'against a model proved in Lean.',
    publication: .unpublished,
  ),

  /// The package that pins real codebases for tools to be tested against.
  muster(
    summary: 'Real codebases to test your Dart tools against.',
    lead: 'Pin the projects your tool gets tested against, and ',
    tail:
        ' brings each one to that commit, resolved and ready to read. Your '
        'tool is then tested on real code people wrote, and every run sees '
        'exactly the same code.',
    publication: .unpublished,
  );

  const Tool({
    required this.summary,
    required this.lead,
    required this.tail,
    required this.publication,
  });

  /// What the tool is, in one line.
  final String summary;

  /// The description's words before the tool's name.
  final String lead;

  /// The description's words after the tool's name.
  final String tail;

  /// Where the tool's versions are published.
  final Publication publication;

  /// The tool's repository on GitHub.
  String get source => '${Elsewhere.githubOrg.href}/$name';

  /// The tool's package on pub.dev, or null while it has none there.
  String? get package => publication.packageOf(name);

  /// Whether any tool is published on pub.dev, so the publisher's page lists
  /// one.
  static bool get anyOnPub => values.any((Tool tool) => tool.publication.onPub);
}
