/// Where a tool's versions are published, beside its source.
enum Publication {
  /// No version published yet.
  unpublished,

  /// Its versions published on pub.dev, under the `lewis.software` publisher.
  pub;

  /// Whether this publication is on pub.dev.
  bool get onPub => switch (this) {
    .unpublished => false,
    .pub => true,
  };

  /// The pub.dev page of the package [name] under this publication, or null
  /// where it has none there.
  String? packageOf(String name) => switch (this) {
    .unpublished => null,
    .pub => 'https://pub.dev/packages/$name',
  };
}
