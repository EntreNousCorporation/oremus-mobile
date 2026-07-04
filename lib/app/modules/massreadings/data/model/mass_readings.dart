/// Lectures de la messe du jour, telles qu'exposees par le backend Oremus
/// (endpoint public `GET /mass-readings/{today|date}`, source AELF).
class MassReadings {
  String? date;
  String? tempsLiturgique;
  String? jourLiturgique;
  String? degre;
  String? couleur;
  List<Reading> readings;

  MassReadings({
    this.date,
    this.tempsLiturgique,
    this.jourLiturgique,
    this.degre,
    this.couleur,
    this.readings = const [],
  });

  MassReadings.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        tempsLiturgique = json['tempsLiturgique'],
        jourLiturgique = json['jourLiturgique'],
        degre = json['degre'],
        couleur = json['couleur'],
        readings = (json['readings'] as List?)
                ?.map((e) => Reading.fromJson(e))
                .toList() ??
            [];
}

/// Une lecture : `contenu` (et `refrainPsalmique`) sont du HTML a rendre tel quel.
class Reading {
  String? type;
  String? titre;
  String? reference;
  String? contenu;
  String? refrainPsalmique;
  String? introLue;
  String? versetEvangile;

  Reading({
    this.type,
    this.titre,
    this.reference,
    this.contenu,
    this.refrainPsalmique,
    this.introLue,
    this.versetEvangile,
  });

  Reading.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        titre = json['titre'],
        reference = json['reference'],
        contenu = json['contenu'],
        refrainPsalmique = json['refrainPsalmique'],
        introLue = json['introLue'],
        versetEvangile = json['versetEvangile'];
}
