class PlaceResponse {
  List<ContentPlace>? content;
  Pageable? pageable;
  int? totalPages;
  int? totalElements;
  bool? last;
  bool? first;
  int? numberOfElements;
  Sort? sort;
  int? number;
  int? size;
  bool? empty;

  PlaceResponse({
    this.content,
    this.pageable,
    this.totalPages,
    this.last,
    this.first,
    this.numberOfElements,
    this.sort,
    this.number,
    this.size,
    this.empty,
  });

  PlaceResponse.fromJson(Map<String, dynamic> json) {
    content = json['content'] != null
        ? (json['content'] as List)
        .map((i) => ContentPlace.fromJson(i))
        .toList()
        : null;
    pageable = json['pageable'] != null
        ? Pageable.fromJson(json['pageable'])
        : null;
    totalPages = json['totalPages'];
    last = json['last'];
    first = json['first'];
    numberOfElements = json['numberOfElements'];
    sort = json['sort'] != null
        ? Sort.fromJson(json['sort'])
        : null;
    number = json['number'];
    size = json['size'];
    empty = json['empty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content?.map((v) => v.toJson()).toList();
    }
    data['pageable'] = pageable?.toJson();
    data['totalPages'] = totalPages;
    data['last'] = last;
    data['first'] = first;
    data['numberOfElements'] = numberOfElements;
    data['sort'] = sort?.toJson();
    data['number'] = number;
    data['size'] = size;
    data['empty'] = empty;
    return data;
  }
}

class Pageable {
  Sort? sort;
  int? pageNumber;
  int? pageSize;
  int? offset;
  bool? paged;
  bool? unpaged;

  Pageable({
    this.sort,
    this.pageNumber,
    this.pageSize,
    this.offset,
    this.paged,
  });

  Pageable.fromJson(Map<String, dynamic> json) {
    sort = json['sort'] != null
        ? Sort.fromJson(json['sort'])
        : null;
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    offset = json['offset'];
    paged = json['paged'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sort'] = sort?.toJson();
    data['pageNumber'] = pageNumber;
    data['pageSize'] = pageSize;
    data['offset'] = offset;
    data['paged'] = paged;
    return data;
  }
}

class Sort {
  bool? unsorted;
  bool? sorted;
  bool? empty;

  Sort({
    this.unsorted,
    this.sorted,
    this.empty,
  });

  Sort.fromJson(Map<String, dynamic> json) {
    unsorted = json['unsorted'];
    sorted = json['sorted'];
    empty = json['empty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unsorted'] = unsorted;
    data['sorted'] = sorted;
    data['empty'] = empty;
    return data;
  }
}

class ContentPlace {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
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

  ContentPlace({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.name,
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
  });

  ContentPlace.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    code = json['code'];
    description = json['description'];
    leader = json['leader'];
    isArchDiocese = json['isArchDiocese'];
    isFavorite = json['isFavorite'] ?? false;
    type = json['type'] != null
        ? TypeContent.fromJson(json['type'])
        : null;
    address = json['address'] != null
        ? Address.fromJson(json['address'])
        : null;
    diocese = json['diocese'] != null
        ? Diocese.fromJson(json['diocese'])
        : null;
    localisation = json['localisation'] != null
        ? Localisation.fromJson(json['localisation'])
        : null;
    coverImage = json['coverImage'] != null
        ? CoverImage.fromJson(json['coverImage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
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


