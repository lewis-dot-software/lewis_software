/// What a message sent from the contact page is about, as its sender chose.
enum Topic {
  /// A tool or app lewis.software already publishes.
  existing('An existing tool or app'),

  /// An app or website made to order.
  commission('An app or website built for you'),

  /// Anything the other topics do not cover.
  other('Anything else');

  const Topic(this.label);

  /// The name the Worker reads the chosen topic by.
  static const String fieldName = 'topic';

  /// The words that label the choice of topic.
  static const String legend = 'What is it about?';

  /// The topic's words, which the form sends as its value, so the message
  /// reads as the sender saw it.
  final String label;
}
