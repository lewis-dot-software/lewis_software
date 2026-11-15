import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'promise.dart';

/// A [Promise]'s sign, in its colour, hidden from assistive technology.
final class Mark extends StatelessComponent {
  /// The sign of [promise].
  const Mark(this.promise, {super.key});

  /// The side whose sign this is.
  final Promise promise;

  @override
  Component build(BuildContext context) => span(
    classes: 'mark mark-${promise.name}',
    attributes: {'aria-hidden': 'true'},
    [.text(promise.mark)],
  );
}
