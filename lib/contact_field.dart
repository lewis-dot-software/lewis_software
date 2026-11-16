/// A field the sender fills in on the contact form, each one required, its
/// [name] the one the Worker reads it by.
enum ContactField {
  /// The sender's name.
  name(label: 'Name', maxLength: 200),

  /// The sender's address, which the message takes as its reply-to.
  email(label: 'Email', maxLength: 254),

  /// What the sender wrote.
  message(label: 'Message', maxLength: 10000);

  const ContactField({required this.label, required this.maxLength});

  /// The words that label the field.
  final String label;

  /// The most characters the field takes.
  final int maxLength;

  /// The `id` of the field's control, which its label names.
  // `this.` reaches the enum's own name, which the value `name` shadows.
  String get id => 'contact-${this.name}';
}
