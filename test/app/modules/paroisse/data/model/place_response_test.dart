import 'package:flutter_test/flutter_test.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

void main() {
  group('ContentPlace.fromJson', () {
    test('parse les champs scalaires', () {
      final place = ContentPlace.fromJson({
        'identifier': 7,
        'name': 'Sainte Bakhita',
        'massInfo': 'Messe à 7h',
        'code': 'SB',
        'description': 'Paroisse',
        'leader': 'Père X',
        'isArchDiocese': false,
      });
      expect(place.identifier, 7);
      expect(place.name, 'Sainte Bakhita');
      expect(place.massInfo, 'Messe à 7h');
      expect(place.code, 'SB');
      expect(place.leader, 'Père X');
      expect(place.isArchDiocese, false);
    });

    test('isFavorite et isUserFavorite défaut false quand absents', () {
      final place = ContentPlace.fromJson({'identifier': 1});
      expect(place.isFavorite, false);
      expect(place.isUserFavorite, false);
    });

    test('address en Map est parsée en Address', () {
      final place = ContentPlace.fromJson({
        'address': {
          'identifier': 13,
          'city': 'Abidjan',
          'municipality': 'Cocody',
          'neighbourhood': '2 Plateaux',
        },
      });
      expect(place.address, isNotNull);
      expect(place.address?.city, 'Abidjan');
      expect(place.address?.municipality, 'Cocody');
      expect(place.address?.neighbourhood, '2 Plateaux');
    });

    test('address en String est splittée en city/municipality/neighbourhood', () {
      final place = ContentPlace.fromJson({
        'address': 'Abidjan Cocody Djibi 8e Tranche',
      });
      expect(place.address, isNotNull);
      expect(place.address?.city, 'Abidjan');
      expect(place.address?.municipality, 'Cocody');
      expect(place.address?.neighbourhood, 'Djibi 8e Tranche');
    });

    test('address String avec un seul mot tombe en city seul', () {
      final place = ContentPlace.fromJson({'address': 'Abidjan'});
      expect(place.address?.city, 'Abidjan');
      expect(place.address?.municipality, isNull);
    });

    test('diocese en Map est parsé', () {
      final place = ContentPlace.fromJson({
        'diocese': {
          'identifier': 2,
          'name': "Diocèse d'Agboville",
          'isArchDiocese': false,
        },
      });
      expect(place.diocese?.name, "Diocèse d'Agboville");
      expect(place.diocese?.identifier, 2);
    });

    test('dioceseName en String quand diocese absent crée un Diocese minimal', () {
      final place = ContentPlace.fromJson({
        'dioceseName': "Archidiocèse d'Abidjan",
      });
      expect(place.diocese, isNotNull);
      expect(place.diocese?.name, "Archidiocèse d'Abidjan");
      expect(place.diocese?.identifier, isNull);
    });

    test('coverImage en Map est parsée', () {
      final place = ContentPlace.fromJson({
        'coverImage': {'name': 'cover.jpg', 'link': 'https://cdn/cover.jpg'},
      });
      expect(place.coverImage?.name, 'cover.jpg');
      expect(place.coverImage?.link, 'https://cdn/cover.jpg');
    });

    test('coverImage en String est wrappée en CoverImage avec link', () {
      final place = ContentPlace.fromJson({
        'coverImage': 'https://cdn/photo.jpg',
      });
      expect(place.coverImage, isNotNull);
      expect(place.coverImage?.link, 'https://cdn/photo.jpg');
      expect(place.coverImage?.name, isNull);
    });

    test('localisation en Map est parsée', () {
      final place = ContentPlace.fromJson({
        'localisation': {
          'identifier': 3,
          'longitude': -3.98,
          'latitude': 5.36,
        },
      });
      expect(place.localisation?.longitude, -3.98);
      expect(place.localisation?.latitude, 5.36);
    });

    test('type avec translate imbriqué est parsé', () {
      final place = ContentPlace.fromJson({
        'type': {
          'identifier': 1,
          'code': 'CHURCH',
          'translate': {'fr': 'Eglise', 'en': 'Church'},
        },
      });
      expect(place.type?.code, 'CHURCH');
      expect(place.type?.translate?.fr, 'Eglise');
      expect(place.type?.translate?.en, 'Church');
    });

    test('roundtrip toJson -> fromJson préserve les champs principaux', () {
      final original = ContentPlace.fromJson({
        'identifier': 99,
        'name': 'Test',
        'isFavorite': true,
        'address': {'city': 'Abidjan', 'municipality': 'Plateau'},
        'diocese': {'identifier': 1, 'name': 'Diocèse Test'},
      });
      final restored = ContentPlace.fromJson(original.toJson());
      expect(restored.identifier, 99);
      expect(restored.name, 'Test');
      expect(restored.isFavorite, true);
      expect(restored.address?.city, 'Abidjan');
      expect(restored.diocese?.name, 'Diocèse Test');
    });
  });
}
