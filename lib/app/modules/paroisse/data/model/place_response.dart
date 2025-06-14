import 'package:oremusapp/app/remote/to_json_interface.dart';

class ContentPlace extends ToJsonInterface {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? massInfo;
  String? code;
  String? description;
  TypeContent? type;
  String? leader;
  bool? isArchDiocese;
  bool? isFavorite;
  Address? address;
  Diocese? diocese;
  Localisation? localisation;
  CoverImage? coverImage;
  bool? isUserFavorite;

  ContentPlace({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.name,
    this.massInfo,
    this.code,
    this.description,
    this.type,
    this.leader,
    this.isArchDiocese,
    this.isFavorite,
    this.address,
    this.diocese,
    this.localisation,
    this.coverImage,
    this.isUserFavorite,
  });

  ContentPlace.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    massInfo = json['massInfo'];
    code = json['code'];
    description = json['description'];
    leader = json['leader'];
    isArchDiocese = json['isArchDiocese'];
    isFavorite = json['isFavorite'] ?? false;
    isUserFavorite = json['isUserFavorite'] ?? false;
    type = json['type'] != null ? TypeContent.fromJson(json['type']) : null;
    if (json['address'] != null && json['address'] is Map) {
      address = Address.fromJson(json['address']);
    } else if (json['address'] != null && json['address'] is String) {
      // Parser la string d'adresse pour extraire les informations
      address = _parseAddressString(json['address']);
    }
    if (json['diocese'] != null && json['diocese'] is Map) {
      diocese = Diocese.fromJson(json['diocese']);
    } else if (json['dioceseName'] != null && json['dioceseName'] is String) {
      // Créer un objet Diocese à partir du nom
      diocese = Diocese(name: json['dioceseName']);
    }
    localisation = json['localisation'] != null
        ? Localisation.fromJson(json['localisation'])
        : null;
    if (json['coverImage'] != null) {
      if (json['coverImage'] is Map) {
        coverImage = CoverImage.fromJson(json['coverImage']);
      } else if (json['coverImage'] is String) {
        // Créer un objet CoverImage à partir de l'URL
        coverImage = CoverImage(link: json['coverImage']);
      }
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['massInfo'] = massInfo;
    data['code'] = code;
    data['description'] = description;
    data['leader'] = leader;
    data['isArchDiocese'] = isArchDiocese;
    data['isFavorite'] = isFavorite;
    data['type'] = type?.toJson();
    data['address'] = address?.toJson();
    data['diocese'] = diocese?.toJson();
    data['localisation'] = localisation?.toJson();
    data['coverImage'] = coverImage?.toJson();
    return data;
  }
}

// Méthode helper pour parser la string d'adresse
Address? _parseAddressString(String addressString) {
  try {
    // Parser "Abidjan Cocody Djibi 8e Tranche"
    List<String> parts = addressString.split(RegExp(r'\s'));
    if (parts.length >= 2) {
      return Address(
        city: parts[0], // "Abidjan"
        municipality: parts.length > 1 ? parts[1] : null, // "Cocody"
        neighbourhood: parts.length > 2
            ? parts.sublist(2).join(' ')
            : null, // "Djibi 8e Tranche"
      );
    }
    return Address(city: addressString);
  } catch (e) {
    return Address(city: addressString);
  }
}

class TypeContent {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? code;
  TranslateContent? translate;

  TypeContent({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.code,
    this.translate,
  });

  TypeContent.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    code = json['code'];
    translate = json['translate'] != null
        ? TranslateContent.fromJson(json['translate'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['code'] = code;
    data['translate'] = translate?.toJson();
    return data;
  }
}

class TranslateContent {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? fr;
  String? en;

  TranslateContent({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.fr,
    this.en,
  });

  TranslateContent.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    fr = json['fr'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['fr'] = fr;
    data['en'] = en;
    return data;
  }
}

class Address {
  int? identifier;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? modifiedBy;
  String? name;
  String? municipality;
  String? city;
  String? neighbourhood;

  Address({
    this.identifier,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.modifiedBy,
    this.name,
    this.municipality,
    this.city,
    this.neighbourhood,
  });

  Address.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    createdBy = json['createdBy'];
    updatedAt = json['updatedAt'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    municipality = json['municipality'];
    city = json['city'];
    neighbourhood = json['neighbourhood'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['createdBy'] = createdBy;
    data['updatedAt'] = updatedAt;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['municipality'] = municipality;
    data['city'] = city;
    data['neighbourhood'] = neighbourhood;
    return data;
  }
}

class Diocese {
  int? identifier;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? modifiedBy;
  String? name;
  bool? isArchDiocese;

  Diocese({
    this.identifier,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.modifiedBy,
    this.name,
    this.isArchDiocese,
  });

  Diocese.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    createdBy = json['createdBy'];
    updatedAt = json['updatedAt'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    isArchDiocese = json['isArchDiocese'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['createdBy'] = createdBy;
    data['updatedAt'] = updatedAt;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['isArchDiocese'] = isArchDiocese;
    return data;
  }
}

class Localisation {
  int? identifier;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? modifiedBy;
  dynamic longitude;
  dynamic latitude;

  Localisation({
    this.identifier,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.modifiedBy,
    this.longitude,
    this.latitude,
  });

  Localisation.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    createdBy = json['createdBy'];
    updatedAt = json['updatedAt'];
    modifiedBy = json['modifiedBy'];
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['createdBy'] = createdBy;
    data['updatedAt'] = updatedAt;
    data['modifiedBy'] = modifiedBy;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}

class CoverImage {
  String? name;
  String? link;

  CoverImage({
    this.name,
    this.link,
  });

  CoverImage.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['link'] = link;
    return data;
  }
}
