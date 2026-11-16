/// The strokes of the site's logo, a terminal's prompt and then `ls`, each
/// drawn in a 32-unit square whose text line runs from 7.4 to 24.6.
enum LogoStroke {
  /// The prompt, as tall as the `l`, its point at the `l`'s middle.
  prompt('M4 8.1L9.4 16L4 23.9'),

  /// The `l`: a stem with no spur, a curved foot, and a tail that turns up
  /// at its end.
  ell(
    'M13.6 7.4V20.2C13.6 22.3 14.7 23.4 16.8 23.4H17.3C18.3 23.4 18.9 22.9 '
    '19.1 21.9',
  ),

  /// The `s`, rounded.
  ess(
    'M28.2 15C27.6 13.9 26.6 13.4 25.4 13.4H25C23.7 13.4 22.8 14.2 22.8 '
    '15.3V15.8C22.8 16.9 23.6 17.6 24.8 18L26.4 18.6C27.6 19 28.4 19.7 28.4 '
    '20.9V21.4C28.4 22.6 27.4 23.4 26 23.4H25.4C24 23.4 23 22.8 22.5 21.7',
  );

  /// The stroke's drawing.
  const LogoStroke(this.path);

  /// The stroke's SVG path data.
  final String path;
}
