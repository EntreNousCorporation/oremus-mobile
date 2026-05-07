import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';
import 'package:oremusapp/app/modules/payment/controller/payment_status_controller.dart';

/// Fakes plutôt que mocktail : `MassRequest/DonationHistoryController`
/// héritent de `GetxController` qui expose un final `onStart` ; quand on les
/// passe à `Get.put`, le framework lit ce champ. Mocktail renverrait `null`
/// → cast error. En étendant `GetxController` directement, on garde un vrai
/// `onStart` et on n'implémente que ce qui est exercé par doRedirection.
class _FakeMassRequestHistoryController extends GetxController
    implements MassRequestHistoryController {
  int refreshCalls = 0;

  @override
  refreshData() {
    refreshCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeDonationHistoryController extends GetxController
    implements DonationHistoryController {
  int refreshCalls = 0;

  @override
  refreshData() {
    refreshCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  // `doRedirection` finit par un `Get.offNamed(...)` qui passe par
  // WidgetsBinding.instance ; sans ça → "Binding has not been initialized".
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LoggerService.initialize(showAppLogs: false);
  });

  setUp(() {
    Get.reset();
    // Get.reset() peut remettre testMode à false ; on le re-affirme.
    Get.testMode = true;
  });

  group('PaymentStatusController.getArguments', () {
    test(
        'paymentType + paroisse_selected + payment_status_message hydratés '
        'depuis args injectés', () {
      final controller = PaymentStatusController();
      controller.getArguments(args: {
        'payment_type': PaymentType.donation,
        'paroisse_selected': {'identifier': 42, 'name': 'Bakhita'},
        'payment_status_message': 'Votre don a été effectué avec succès',
      });

      expect(controller.paymentType.value, PaymentType.donation);
      expect(controller.paroisseSelected.value.identifier, 42);
      expect(controller.paroisseSelected.value.name, 'Bakhita');
      expect(controller.paymentStatusMessage.value,
          'Votre don a été effectué avec succès');
    });

    test('args null → controller reste sur défauts', () {
      final controller = PaymentStatusController();
      controller.getArguments(args: null);

      expect(controller.paymentType.value, PaymentType.none);
      expect(controller.paymentStatusMessage.value, '');
    });

    test('args partiels → seuls les champs présents sont hydratés', () {
      final controller = PaymentStatusController();
      controller.getArguments(args: {'payment_type': PaymentType.massRequest});

      expect(controller.paymentType.value, PaymentType.massRequest);
      expect(controller.paymentStatusMessage.value, '');
    });
  });

  group('PaymentStatusController.doRedirection', () {
    test('massRequest → refresh MassRequestHistoryController si enregistré',
        () {
      final fakeHistory = _FakeMassRequestHistoryController();
      Get.put<MassRequestHistoryController>(fakeHistory);

      final controller = PaymentStatusController();
      controller.getArguments(args: {'payment_type': PaymentType.massRequest});

      controller.doRedirection();

      expect(fakeHistory.refreshCalls, 1);
    });

    test('donation → refresh DonationHistoryController si enregistré', () {
      final fakeHistory = _FakeDonationHistoryController();
      Get.put<DonationHistoryController>(fakeHistory);

      final controller = PaymentStatusController();
      controller.getArguments(args: {'payment_type': PaymentType.donation});

      controller.doRedirection();

      expect(fakeHistory.refreshCalls, 1);
    });

    test('massRequest sans controller historique enregistré → pas de crash',
        () {
      final controller = PaymentStatusController();
      controller.getArguments(args: {'payment_type': PaymentType.massRequest});

      // Pas de Get.put préalable : Get.isRegistered renvoie false → on ne
      // doit jamais appeler Get.find (qui throwerait).
      expect(() => controller.doRedirection(), returnsNormally);
    });

    test('paymentType.none → no-op (pas de refresh)', () {
      final fakeHistory = _FakeMassRequestHistoryController();
      Get.put<MassRequestHistoryController>(fakeHistory);

      final controller = PaymentStatusController();
      controller.getArguments(args: {'payment_type': PaymentType.none});

      controller.doRedirection();

      expect(fakeHistory.refreshCalls, 0);
    });
  });
}
