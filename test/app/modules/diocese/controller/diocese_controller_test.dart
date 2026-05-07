import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/app/modules/diocese/controller/diocese_controller.dart';
import 'package:oremusapp/app/modules/diocese/data/repository/diocese_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/remote/data_response.dart';

class _MockDioceseRepository extends Mock implements DioceseRepository {}

void main() {
  setUpAll(() async {
    Get.testMode = true;
    await LoggerService.initialize(showAppLogs: false);
  });

  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  DataResponse<ContentPlace> dioceseResponse({required bool empty,
      List<ContentPlace>? items}) {
    return DataResponse<ContentPlace>(empty: empty, contents: items);
  }

  group('DioceseController.getDioceses', () {
    test('liste non vide → hasData = true et dioceses peuplé', () async {
      final repo = _MockDioceseRepository();
      when(() => repo.getDioceses(page: any(named: 'page')))
          .thenAnswer((_) async => dioceseResponse(empty: false, items: [
                ContentPlace.fromJson({'identifier': 1, 'name': 'Abidjan'}),
                ContentPlace.fromJson({'identifier': 2, 'name': 'Yopougon'}),
              ]));

      final controller = DioceseController(dioceseRepository: repo);
      controller.getDioceses();
      await Future<void>.delayed(Duration.zero);

      expect(controller.isDataProcessing.value, false);
      expect(controller.hasData.value, true);
      expect(controller.dioceses, hasLength(2));
      expect(controller.dioceses[0]?.name, 'Abidjan');
    });

    test('liste vide → hasData = false', () async {
      final repo = _MockDioceseRepository();
      when(() => repo.getDioceses(page: any(named: 'page')))
          .thenAnswer((_) async => dioceseResponse(empty: true, items: []));

      final controller = DioceseController(dioceseRepository: repo);
      controller.getDioceses();
      await Future<void>.delayed(Duration.zero);

      expect(controller.hasData.value, false);
      expect(controller.dioceses, isEmpty);
    });

    test('repo erreur async → hasData = false et processing remis à false',
        () async {
      final repo = _MockDioceseRepository();
      when(() => repo.getDioceses(page: any(named: 'page')))
          .thenAnswer((_) async => throw Exception('boom'));

      final controller = DioceseController(dioceseRepository: repo);
      controller.getDioceses();
      await Future<void>.delayed(Duration.zero);

      expect(controller.isDataProcessing.value, false);
      expect(controller.hasData.value, false);
    });

    test('isDataProcessing flip true puis false', () async {
      final repo = _MockDioceseRepository();
      when(() => repo.getDioceses(page: any(named: 'page')))
          .thenAnswer((_) async => dioceseResponse(empty: true, items: []));

      final controller = DioceseController(dioceseRepository: repo);
      controller.getDioceses();
      // Avant que le Future résolve : processing = true
      expect(controller.isDataProcessing.value, true);
      await Future<void>.delayed(Duration.zero);
      // Après : remis à false
      expect(controller.isDataProcessing.value, false);
    });
  });

  group('DioceseController.onRefresh', () {
    test('met à jour la liste sans toucher hasData', () async {
      final repo = _MockDioceseRepository();
      when(() => repo.getDioceses(page: any(named: 'page')))
          .thenAnswer((_) async => dioceseResponse(empty: false, items: [
                ContentPlace.fromJson({'identifier': 9, 'name': 'Bouaké'}),
              ]));

      final controller = DioceseController(dioceseRepository: repo);
      controller.onRefresh();
      await Future<void>.delayed(Duration.zero);

      expect(controller.dioceses, hasLength(1));
      expect(controller.dioceses[0]?.name, 'Bouaké');
    });

    test('repo erreur async pendant refresh → pas de crash, liste préservée',
        () async {
      final repo = _MockDioceseRepository();
      when(() => repo.getDioceses(page: any(named: 'page')))
          .thenAnswer((_) async => throw Exception('refresh failed'));

      final controller = DioceseController(dioceseRepository: repo);
      // L'erreur va dans le onError handler (debugPrint) — le test doit
      // simplement ne pas exploser.
      controller.onRefresh();
      await Future<void>.delayed(Duration.zero);
      expect(controller.dioceses, isEmpty);
    });
  });
}
