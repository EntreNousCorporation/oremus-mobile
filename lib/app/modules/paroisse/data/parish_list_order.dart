import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

/// Favoris en tête (A → Z), puis les autres paroisses.
///
/// [knownFavorites] sont fusionnés pour qu'un favori absent de la page
/// courante apparaisse quand même. L'identifiant déduplique : la fiche
/// déjà dans [parishes] est gardée (données serveur), avec le drapeau favori.
///
/// [sortRemainderByName] aligne le reste sur le tri `name,ASC` de la liste
/// d'accueil. En recherche, le laisser à false conserve l'ordre du serveur.
List<ContentPlace?> orderParishesFavoritesFirst(
  List<ContentPlace?> parishes, {
  List<ContentPlace> knownFavorites = const [],
  bool sortRemainderByName = false,
}) {
  final ordered = <ContentPlace?>[];
  final indexById = <dynamic, int>{};

  void addPlace(ContentPlace? place, {required bool forceFavorite}) {
    if (place == null) {
      ordered.add(null);
      return;
    }
    if (forceFavorite) {
      place.isFavorite = true;
    }
    final id = place.identifier;
    if (id == null) {
      ordered.add(place);
      return;
    }
    final existingIndex = indexById[id];
    if (existingIndex == null) {
      indexById[id] = ordered.length;
      ordered.add(place);
      return;
    }
    final existing = ordered[existingIndex];
    if (existing == null) return;
    final favorite =
        existing.isFavorite == true ||
        place.isFavorite == true ||
        forceFavorite;
    if (!forceFavorite) {
      place.isFavorite = favorite;
      ordered[existingIndex] = place;
    } else {
      existing.isFavorite = favorite;
    }
  }

  for (final favorite in knownFavorites) {
    addPlace(favorite, forceFavorite: true);
  }
  for (final place in parishes) {
    addPlace(place, forceFavorite: false);
  }

  final favorites = <ContentPlace?>[];
  final others = <ContentPlace?>[];
  for (final place in ordered) {
    if (place?.isFavorite == true) {
      favorites.add(place);
    } else {
      others.add(place);
    }
  }

  favorites.sort(_byName);
  if (sortRemainderByName) {
    others.sort(_byName);
  }
  return [...favorites, ...others];
}

int _byName(ContentPlace? a, ContentPlace? b) {
  return (a?.name ?? '').toLowerCase().compareTo((b?.name ?? '').toLowerCase());
}
