import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'contact_field.dart';

/// A [ContactField] on the contact form: its label above its control.
final class FieldControl extends StatelessComponent {
  /// The control of [field], described by the element whose `id` is
  /// [describedBy], where one is given.
  const FieldControl(this.field, {this.describedBy, super.key});

  /// The field this control fills in.
  final ContactField field;

  /// The `id` of the hint that describes the control, if any.
  final String? describedBy;

  @override
  Component build(BuildContext context) {
    final Map<String, String> attributes = {
      'required': '',
      'maxlength': '${field.maxLength}',
      'aria-describedby': ?describedBy,
    };
    return div(classes: 'field', [
      label(htmlFor: field.id, [.text(field.label)]),
      switch (field) {
        .name => input(
          type: .text,
          id: field.id,
          name: field.name,
          attributes: {...attributes, 'autocomplete': 'name'},
        ),
        .email => input(
          type: .email,
          id: field.id,
          name: field.name,
          attributes: {...attributes, 'autocomplete': 'email'},
        ),
        .message => textarea(
          id: field.id,
          name: field.name,
          rows: 8,
          attributes: attributes,
          [],
        ),
      },
    ]);
  }
}
