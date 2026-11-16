import 'package:lewis_software/publication.dart';
import 'package:test/test.dart';

void main() {
  test('an unpublished tool is not on pub.dev and has no package there', () {
    expect(Publication.unpublished.onPub, isFalse);
    expect(Publication.unpublished.packageOf('grit'), isNull);
  });

  test("a tool on pub.dev has its package's page there", () {
    expect(Publication.pub.onPub, isTrue);
    expect(Publication.pub.packageOf('grit'), 'https://pub.dev/packages/grit');
  });
}
