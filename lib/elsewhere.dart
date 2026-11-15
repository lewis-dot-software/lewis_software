/// The address readers write to Dan at.
const String emailAddress = 'dan@lewis.software';

/// A place off the site that its pages link to.
enum Elsewhere {
  /// A new email to [emailAddress].
  email('mailto:$emailAddress'),

  /// The `lewis-dot-software` organisation on GitHub, which holds the source
  /// of every public tool.
  githubOrg('https://github.com/lewis-dot-software'),

  /// The `lewis.software` publisher on pub.dev, which lists every published
  /// package.
  pubPublisher('https://pub.dev/publishers/lewis.software'),

  /// The source of this site.
  siteSource('https://github.com/lewis-dot-software/lewis_software');

  const Elsewhere(this.href);

  /// The link's target.
  final String href;
}
