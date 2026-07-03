/// Lectures de la messe du jour, telles qu'exposees par le backend Oremus
/// (endpoint public `GET /mass-readings/{today|date}`, source AELF).
class MassReadings {
  String? date;
  String? tempsLiturgique;
  String? fete;
  String? couleur;
  List<Reading> readings;

  MassReadings({
    this.date,
    this.tempsLiturgique,
    this.fete,
    this.couleur,
    this.readings = const [],
  });

  MassReadings.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        tempsLiturgique = json['tempsLiturgique'],
        fete = json['fete'],
        couleur = json['couleur'],
        readings = (json['readings'] as List?)
                ?.map((e) => Reading.fromJson(e))
                .toList() ??
            [];
}

/// Une lecture : `contenu` est du HTML a rendre tel quel.
class Reading {
  String? type;
  String? titre;
  String? reference;
  String? contenu;

  Reading({this.type, this.titre, this.reference, this.contenu});

  Reading.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        titre = json['titre'],
        reference = json['reference'],
        contenu = json['contenu'];
}
