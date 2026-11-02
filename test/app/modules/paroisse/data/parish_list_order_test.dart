import 'package:flutter_test/flutter_test.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/parish_list_order.dart';

ContentPlace place(
  dynamic id,
  String name, {
  bool favorite = false,
  String? massInfo,
}) {
  return ContentPlace(
    identifier: id,
    name: name,
    isFavorite: favorite,
    massInfo: massInfo,
  );
}

void main() {
  group('orderParishesFavoritesFirst', () {
    test(
      'les favoris passent devant, triés par nom, le reste garde l’ordre serveur',
      () {
        final ordered = orderParishesFavoritesFirst([
          place(1, 'Alpha'),
          place(2, 'Zénith', favorite: true),
          place(3, 'Milieu'),
          place(4, 'Bakhita', favorite: true),
        ]);

        expect(ordered.map((p) => p?.name).toList(), [
          'Bakhita',
          'Zénith',
          'Alpha',
          'Milieu',
        ]);
      },
    );

    test('un favori connu absent de la page est ajouté en tête', () {
      final ordered = orderParishesFavoritesFirst(
        [place(1, 'Alpha'), place(3, 'Milieu')],
        knownFavorites: [place(9, 'Saint Zéphirin')],
        sortRemainderByName: true,
      );

      expect(ordered.map((p) => p?.name).toList(), [
        'Saint Zéphirin',
        'Alpha',
        'Milieu',
      ]);
      expect(ordered.first?.isFavorite, true);
    });

    test(
      'le même identifiant n’apparaît qu’une fois, avec la fiche serveur',
      () {
        final ordered = orderParishesFavoritesFirst(
          [place(1, 'Alpha'), place(2, 'Saint Zéphirin', massInfo: 'Messe 9h')],
          knownFavorites: [place(2, 'Saint Zéphirin')],
        );

        expect(ordered.map((p) => p?.identifier).toList(), [2, 1]);
        expect(ordered.first?.isFavorite, true);
        expect(ordered.first?.massInfo, 'Messe 9h');
      },
    );

    test(
      'sans favoris connus, le tri alphabétique du reste replace un ex-favori',
      () {
        final zephirin = place(9, 'Saint Zéphirin', favorite: false);
        final ordered = orderParishesFavoritesFirst([
          zephirin,
          place(1, 'Alpha'),
          place(3, 'Milieu'),
        ], sortRemainderByName: true);

        expect(ordered.map((p) => p?.name).toList(), [
          'Alpha',
          'Milieu',
          'Saint Zéphirin',
        ]);
      },
    );
  });
}
