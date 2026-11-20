import 'dart:io';

import 'package:test/test.dart';

/// The headers `web/_headers` sets on every path, by lower-cased name.
Map<String, String> _everyPathHeaders() {
  final Map<String, String> headers = {};
  String? rule;
  for (final String line in File('web/_headers').readAsLinesSync()) {
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    if (!line.startsWith(' ')) {
      rule = line.trim();
    } else if (rule == '/*') {
      final int colon = line.indexOf(':');
      headers[line.substring(0, colon).trim().toLowerCase()] = line
          .substring(colon + 1)
          .trim();
    }
  }
  return headers;
}

/// One directive of a policy: its name, then its value after any `=`.
final RegExp _directive = .new(r'^([a-z-]+)[\s=]*(.*)$');

/// The directives of a policy split by [separator], each name to its value.
Map<String, String> _directives(String policy, String separator) => {
  for (final String directive in policy.split(separator))
    if (_directive.firstMatch(directive.trim()) case final RegExpMatch match)
      match.group(1)!: match.group(2)!,
};

/// Every feature MDN's Permissions-Policy reference lists that Chrome
/// recognises.
const List<String> _features = [
  'accelerometer',
  'aria-notify',
  'autoplay',
  'bluetooth',
  'browsing-topics',
  'camera',
  'captured-surface-control',
  'ch-ua-high-entropy-values',
  'compute-pressure',
  'cross-origin-isolated',
  'deferred-fetch',
  'deferred-fetch-minimal',
  'display-capture',
  'encrypted-media',
  'fullscreen',
  'gamepad',
  'geolocation',
  'gyroscope',
  'hid',
  'identity-credentials-get',
  'idle-detection',
  'language-detector',
  'language-model',
  'local-fonts',
  'local-network',
  'local-network-access',
  'loopback-network',
  'magnetometer',
  'microphone',
  'midi',
  'on-device-speech-recognition',
  'otp-credentials',
  'payment',
  'picture-in-picture',
  'private-state-token-issuance',
  'private-state-token-redemption',
  'publickey-credentials-create',
  'publickey-credentials-get',
  'screen-wake-lock',
  'serial',
  'speaker-selection',
  'storage-access',
  'summarizer',
  'translator',
  'unload',
  'usb',
  'web-share',
  'window-management',
  'xr-spatial-tracking',
];

/// The features MDN's Permissions-Policy reference lists that Chrome logs as
/// unrecognised, an error in the console of every page that names one.
const List<String> _unrecognisedByChrome = [
  'ambient-light-sensor',
  'attribution-reporting',
];

void main() {
  final Map<String, String> headers = _everyPathHeaders();

  test("the content security policy allows the site's own origin alone", () {
    final Map<String, String> csp = _directives(
      headers['content-security-policy']!,
      ';',
    );
    expect(csp['default-src'], "'self'");
    // Jaspr's Document writes `<base href="/">` into every page.
    expect(csp['base-uri'], "'self'");
    for (final MapEntry(:key, :value) in csp.entries) {
      expect(
        value.split(' '),
        everyElement(isIn(["'self'", "'none'"])),
        reason: key,
      );
    }
  });

  test('HSTS holds the site to HTTPS for a year at least', () {
    final RegExpMatch? maxAge = RegExp(r'^max-age=(\d+)')
        .firstMatch(headers['strict-transport-security']!);
    expect(int.parse(maxAge!.group(1)!), greaterThanOrEqualTo(31536000));
  });

  test('no referrer is sent from the site', () {
    expect(headers['referrer-policy'], 'no-referrer');
  });

  group('the permissions policy', () {
    final Map<String, String> permissions = _directives(
      headers['permissions-policy']!,
      ',',
    );

    test('denies every feature MDN lists that Chrome recognises', () {
      expect(permissions.keys, containsAll(_features));
      expect(permissions.values, everyElement('()'));
    });

    test('names no feature Chrome does not recognise', () {
      expect(
        permissions.keys,
        everyElement(isNot(isIn(_unrecognisedByChrome))),
      );
    });
  });
}
