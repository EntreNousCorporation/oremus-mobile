import 'package:flutter_test/flutter_test.dart';
import 'package:oremusapp/app/modules/payment/utils/payment_url_utils.dart';

void main() {
  group('PaymentUrlUtils.isExternalAppUrl', () {
    test('URL https Wave → true', () {
      expect(
        PaymentUrlUtils.isExternalAppUrl(
            'https://pay.wave.com/c/cos-abc/capture/123'),
        true,
      );
    });

    test('schéma deep link wave:// → true', () {
      expect(
        PaymentUrlUtils.isExternalAppUrl('wave://pay?ref=xyz'),
        true,
      );
    });

    test('URL CinetPay quelconque → false', () {
      expect(
        PaymentUrlUtils.isExternalAppUrl(
            'https://secure.cinetpay.com/checkout/12345'),
        false,
      );
    });

    test('URL vide → false', () {
      expect(PaymentUrlUtils.isExternalAppUrl(''), false);
    });

    test('URL contenant wave en sous-string mais pas wave.com → false', () {
      expect(
        PaymentUrlUtils.isExternalAppUrl('https://example.com/wave/page'),
        false,
        reason:
            'on doit matcher seulement le domaine wave.com ou le scheme wave://',
      );
    });
  });

  group('PaymentUrlUtils.extractWaveCaptureUrl', () {
    test('URL Wave standard → split sur capture/', () {
      const url = 'https://pay.wave.com/c/cos-abc/capture/encoded-payload-xyz';
      expect(
        PaymentUrlUtils.extractWaveCaptureUrl(url),
        'encoded-payload-xyz',
      );
    });

    test('URL sans marqueur capture/ → renvoie l\'URL telle quelle', () {
      const url = 'https://pay.wave.com/c/cos-abc/other-path';
      expect(
        PaymentUrlUtils.extractWaveCaptureUrl(url),
        url,
        reason: 'split.last sur une chaîne sans séparateur renvoie la chaîne',
      );
    });

    test('plusieurs occurrences capture/ → garde la dernière', () {
      const url = 'https://pay.wave.com/capture/v1/capture/final-token';
      expect(
        PaymentUrlUtils.extractWaveCaptureUrl(url),
        'final-token',
        reason:
            'split(...).last prend la dernière portion, ce qui est le comportement '
            'historique du _handleInterceptedLink',
      );
    });
  });
}
