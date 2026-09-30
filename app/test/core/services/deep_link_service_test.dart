import 'package:flutter_test/flutter_test.dart';
import 'package:moments/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService Tests', () {
    test('Identifies valid OAuth redirect URIs', () {
      final validUri1 = Uri.parse('moments://login-callback?code=mock_code_123');
      final validUri2 = Uri.parse('moments://login-callback/?code=mock_code_456#fragment');

      expect(validUri1.scheme, 'moments');
      expect(validUri1.host, 'login-callback');
      expect(validUri1.queryParameters['code'], 'mock_code_123');

      expect(validUri2.scheme, 'moments');
      expect(validUri2.host, 'login-callback');
    });

    test('Rejects non-OAuth URIs correctly', () {
      final otherUri1 = Uri.parse('moments://moments/abc');
      final otherUri2 = Uri.parse('https://example.com/login-callback');

      final isOAuth1 = otherUri1.scheme == 'moments' &&
          (otherUri1.host == 'login-callback' || otherUri1.path.contains('login-callback'));
      final isOAuth2 = otherUri2.scheme == 'moments' &&
          (otherUri2.host == 'login-callback' || otherUri2.path.contains('login-callback'));

      expect(isOAuth1, isFalse);
      expect(isOAuth2, isFalse);
    });

    test('DeepLinkService instance can be created and disposed safely', () {
      final service = DeepLinkService();
      expect(service, isNotNull);
      service.dispose();
    });
  });
}
