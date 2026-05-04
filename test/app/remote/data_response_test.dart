import 'package:flutter_test/flutter_test.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/remote/data_response.dart';

void main() {
  group('DataResponse.fromJson<ContentPlace>', () {
    test('sort en Map est parsé en objet Sort', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'sort': {'sorted': true, 'unsorted': false, 'empty': false},
      });
      expect(response.sort, isNotNull);
      expect(response.sort?.sorted, true);
      expect(response.sort?.unsorted, false);
    });

    test('sort en List est ignoré (régression Spring pageable v2)', () {
      // Le backend renvoie maintenant sort sous forme de liste de critères ;
      // sans guard, Sort.fromJson explose car attend un Map.
      final response = DataResponse<ContentPlace>.fromJson({
        'sort': [
          {'direction': 'ASC', 'property': 'name'},
        ],
      });
      expect(response.sort, isNull);
    });

    test('sort absent reste null', () {
      final response = DataResponse<ContentPlace>.fromJson({});
      expect(response.sort, isNull);
    });

    test('pageable en Map est parsé', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'pageable': {
          'pageNumber': 0,
          'pageSize': 10,
          'offset': 0,
          'paged': true,
        },
      });
      expect(response.pageable, isNotNull);
      expect(response.pageable?.pageNumber, 0);
      expect(response.pageable?.pageSize, 10);
      expect(response.pageable?.paged, true);
    });

    test('pageable en List est ignoré', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'pageable': [
          {'pageNumber': 0},
        ],
      });
      expect(response.pageable, isNull);
    });

    test('pageable.sort en List ne fait pas planter Pageable.fromJson', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'pageable': {
          'pageNumber': 0,
          'pageSize': 10,
          'sort': [
            {'direction': 'ASC', 'property': 'name'},
          ],
        },
      });
      expect(response.pageable, isNotNull);
      expect(response.pageable?.sort, isNull);
      expect(response.pageable?.pageNumber, 0);
    });

    test('content en List donne contents non-vide', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'content': [
          {'identifier': 1, 'name': 'Sainte Bakhita'},
          {'identifier': 2, 'name': 'Saint Joseph'},
        ],
        'last': true,
      });
      expect(response.contents, hasLength(2));
      expect(response.contents?[0]?.name, 'Sainte Bakhita');
      expect(response.contents?[1]?.identifier, 2);
      expect(response.last, true);
    });

    test('content en objet seul est mappé sur content (singulier)', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'content': {'identifier': 1, 'name': 'Sainte Bakhita'},
      });
      expect(response.content, isNotNull);
      expect(response.content?.name, 'Sainte Bakhita');
      expect(response.contents, isNull);
    });

    test('content vide donne contents vide (pas null)', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'content': <Map<String, dynamic>>[],
      });
      expect(response.contents, isEmpty);
    });

    test('preserve les champs de pagination scalaires', () {
      final response = DataResponse<ContentPlace>.fromJson({
        'totalPages': 5,
        'totalElements': 42,
        'first': true,
        'last': false,
        'empty': false,
        'number': 0,
        'size': 10,
        'numberOfElements': 10,
      });
      expect(response.totalPages, 5);
      expect(response.totalElements, 42);
      expect(response.first, true);
      expect(response.last, false);
      expect(response.empty, false);
      expect(response.number, 0);
      expect(response.size, 10);
    });
  });
}
