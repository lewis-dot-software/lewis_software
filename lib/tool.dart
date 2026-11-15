import 'elsewhere.dart';

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
  ),

  /// The package that pins real codebases for tools to be tested against.
  muster(
    summary: 'Real codebases to test your Dart tools against.',
    lead: 'Pin the projects your tool gets tested against, and ',
    tail:
        ' brings each one to that commit, resolved and ready to read. Your '
        'tool is then tested on real code people wrote, and every run sees '
        'exactly the same code.',
  );

  const Tool({required this.summary, required this.lead, required this.tail});

  /// What the tool is, in one line.
  final String summary;

  /// The description's words before the tool's name.
  final String lead;

  /// The description's words after the tool's name.
  final String tail;

  /// The tool's repository on GitHub.
  String get source => '${Elsewhere.githubOrg.href}/$name';

  /// The tool's package on pub.dev.
  String get package => 'https://pub.dev/packages/$name';
}
