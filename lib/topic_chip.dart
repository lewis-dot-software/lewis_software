import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'topic.dart';

/// A [Topic] as a chip on the contact form: a radio button inside its label.
final class TopicChip extends StatelessComponent {
  /// The chip of [topic].
  const TopicChip(this.topic, {super.key});

  /// The topic this chip chooses.
  final Topic topic;

  @override
  Component build(BuildContext context) => label(classes: 'chip', [
    input(type: .radio, name: Topic.fieldName, value: topic.label),
    .text(topic.label),
  ]);
}
