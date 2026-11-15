/// One side of what lewis.software's software promises its users.
enum Promise {
  /// What the software always does.
  always(
    mark: '+',
    heading: 'Always',
    pledges: [
      'Says plainly what it does, and what it does with your data.',
      'Works offline, with no account, wherever it can.',
      'Is tested well past what it strictly needs.',
    ],
  ),

  /// What the software never does.
  never(
    mark: '−',
    heading: 'Never',
    pledges: [
      'Tricks you with dark patterns to keep you hooked or paying.',
      'Ships AI-written code without thorough human review.',
      'Sells your data, or collects more than it needs to work. Any crash '
          'reports and analytics are anonymous.',
    ],
  );

  const Promise({
    required this.mark,
    required this.heading,
    required this.pledges,
  });

  /// The sign set before the [heading]: a plus or a minus.
  final String mark;

  /// The side's heading.
  final String heading;

  /// The side's pledges, in the order the page lists them.
  final List<String> pledges;
}
