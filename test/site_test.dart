import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:lewis_software/main.server.options.dart';
import 'package:lewis_software/site.dart';

void main() {
  setUpAll(() => Jaspr.initializeApp(options: defaultServerOptions));

  testServer(
    'the site renders a British English document titled lewis.software',
    (tester) async {
      tester.pumpComponent(const Site());
      final DocumentResponse response = await tester.request('/');
      expect(response.statusCode, 200);
      expect(response.document?.documentElement?.attributes['lang'], 'en-GB');
      expect(response.document?.querySelector('title')?.text, 'lewis.software');
      expect(
        response.document?.querySelector('main h1')?.text,
        'lewis.software',
      );
    },
  );
}
