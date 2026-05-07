import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/payment/controller/payment_controller.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart'
    hide test;

class _MockPaymentRepository extends Mock implements PaymentRepository {}

/// Sous-classe espionne : neutralise les `Get.offNamed/toNamed` (qui ne
/// peuvent pas tourner sans GetMaterialApp en test) et capture la cible.
class _SpyPaymentController extends PaymentController {
  _SpyPaymentController({required super.paymentRepository});

  String? lastMove;

  @override
  moveToError() {
    lastMove = 'error';
  }

  @override
  moveToSuccess() {
    lastMove = 'success';
  }

  @override
  void moveToProcessing() {
    lastMove = 'processing';
  }
}

void main() {
  late _MockPaymentRepository repo;
  late _SpyPaymentController controller;

  setUpAll(() async {
    Get.testMode = true;
    // PaymentController loggue via OremusLogger ; sans init le late field
    // explose à la 1ère info().
    await LoggerService.initialize(showAppLogs: false);
  });

  setUp(() {
    repo = _MockPaymentRepository();
    controller = _SpyPaymentController(paymentRepository: repo);
    controller.paymentType.value = PaymentType.massRequest;
    controller.massRequestResponseSelected.value = MassRequestResponse()
      ..transactionId = 'tx-test-1';
  });

  PaymentStatusData status(String s) =>
      PaymentStatusData(paymentStatus: s, transactionId: 'tx-test-1');

  group('doGetPaymentStatus — terminal states', () {
    test('ACCEPTED → moveToSuccess + message massRequest', () async {
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('ACCEPTED'));

      controller.doGetPaymentStatus();
      // laisse le Future du repo se résoudre
      await Future<void>.delayed(Duration.zero);

      expect(controller.lastMove, 'success');
      expect(
        controller.paymentStatusMessage.value,
        'Votre demande de messe a été effectuée avec succès',
      );
      expect(controller.checkingPaymentStatus.value, true);
    });

    test('SUCCESS (donation) → moveToSuccess + message donation', () async {
      controller.paymentType.value = PaymentType.donation;
      controller.donationSelected.value = DonationResponse()
        ..transactionId = 'tx-don-1';
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('SUCCESS'));

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);

      expect(controller.lastMove, 'success');
      expect(
        controller.paymentStatusMessage.value,
        'Votre don a été effectué avec succès',
      );
    });

    test('REFUSED → moveToError + message échec', () async {
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('REFUSED'));

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);

      expect(controller.lastMove, 'error');
      expect(controller.paymentStatusMessage.value,
          'Le paiement a échoué. Veuillez réessayer svp !');
    });

    test('FAILED → moveToError', () async {
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('FAILED'));

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);

      expect(controller.lastMove, 'error');
    });

    test('statut inconnu (NONE) → moveToProcessing', () async {
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('NONE'));

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);

      expect(controller.lastMove, 'processing');
    });
  });

  group('doGetPaymentStatus — états transitoires PENDING/INITIATED/INIT', () {
    test('PENDING : pas de nav, manualVerifyCount incrémenté', () async {
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('PENDING'));

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);

      expect(controller.lastMove, isNull);
      expect(controller.manualVerifyCount.value, 1);
      expect(controller.manualVerify.value, false);
      expect(controller.checkingPaymentStatus.value, false,
          reason: 'le polling doit pouvoir reprendre au tick suivant');
    });

    test('5 PENDING consécutifs → manualVerify passe à true', () async {
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('PENDING'));

      for (var i = 0; i < 5; i++) {
        controller.doGetPaymentStatus();
        await Future<void>.delayed(Duration.zero);
      }

      expect(controller.manualVerifyCount.value, 5);
      expect(controller.manualVerify.value, true,
          reason:
              'au 5e PENDING, le contrôleur force le manualVerify côté API');
    });

    test('INITIATED puis ACCEPTED → 1 PENDING transit, puis success', () async {
      var calls = 0;
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async {
        calls += 1;
        return status(calls == 1 ? 'INITIATED' : 'ACCEPTED');
      });

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);
      expect(controller.lastMove, isNull);
      expect(controller.manualVerifyCount.value, 1);

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);
      expect(controller.lastMove, 'success');
    });
  });

  group('doGetPaymentStatus — guards', () {
    test('appel ré-entrant ignoré si checkingPaymentStatus déjà true', () async {
      controller.checkingPaymentStatus.value = true;

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          ));
    });

    test('endpoint reçoit le bon transactionId selon paymentType', () async {
      when(() => repo.paymentStatus(
            transactionId: any(named: 'transactionId'),
            manualVerify: any(named: 'manualVerify'),
          )).thenAnswer((_) async => status('PENDING'));

      controller.doGetPaymentStatus();
      await Future<void>.delayed(Duration.zero);

      verify(() => repo.paymentStatus(
            transactionId: 'tx-test-1',
            manualVerify: false,
          )).called(1);
    });
  });
}
