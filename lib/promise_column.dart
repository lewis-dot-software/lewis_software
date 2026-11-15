import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'mark.dart';
import 'promise.dart';

/// One side of the promise: its heading under its sign, then its pledges.
final class PromiseColumn extends StatelessComponent {
  /// The column of [promise].
  const PromiseColumn(this.promise, {super.key});

  /// The side this column shows.
  final Promise promise;

  @override
  Component build(BuildContext context) => div(classes: 'promise', [
    h2([Mark(promise), .text(promise.heading)]),
    ul([
      for (final String pledge in promise.pledges) li([.text(pledge)]),
    ]),
  ]);
}
