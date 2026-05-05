import 'package:flutter_test/flutter_test.dart';
import 'package:oremusapp/app/modules/signin/data/model/refresh_token_request.dart';

void main() {
  group('RefreshTokenRequest', () {
    test('toJson sérialise le champ refreshToken', () {
      final request = RefreshTokenRequest(refreshToken: 'abc123');
      expect(request.toJson(), {'refreshToken': 'abc123'});
    });

    test('toJson conserve le champ même quand il est null', () {
      final request = RefreshTokenRequest();
      expect(request.toJson(), {'refreshToken': null});
    });

    test('fromJson lit le champ refreshToken', () {
      final request = RefreshTokenRequest.fromJson({'refreshToken': 'xyz'});
      expect(request.refreshToken, 'xyz');
    });

    test('roundtrip toJson -> fromJson préserve la donnée', () {
      final original = RefreshTokenRequest(refreshToken: 'token-42');
      final restored = RefreshTokenRequest.fromJson(original.toJson());
      expect(restored.refreshToken, original.refreshToken);
    });
  });
}
