///Class used to collect all criterias of advanced search
class SearchCriteria {
  String? name;
  String? type;
  String? diocese;
  String? municipality;
  String? city;
  String? neighborhood;
  int? countCriteria = 0;

  SearchCriteria({
    this.name,
    this.type,
    this.diocese,
    this.municipality,
    this.city,
    this.neighborhood,
  });

  ///use to know if we must launch search or not
  get isCriteriaEmpty => (type == null && diocese == null && municipality == null && city == null && neighborhood == null) || (type?.isEmpty == true && diocese?.isEmpty == true && municipality?.isEmpty == true && city?.isEmpty == true && neighborhood?.isEmpty == true);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['diocese'] = diocese;
    data['municipality'] = municipality;
    data['city'] = city;
    data['neighborhood'] = neighborhood;
    data['isCriteriaEmpty'] = isCriteriaEmpty;
    data['countCriteria'] = countCriteria;
    return data;
  }
}
