import 'package:oremusapp/app/modules/paroisse/data/model/paroisse.dart';

class ParoisseResponse {
  List<ContentParoisse>? content;
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

  ParoisseResponse({
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

  ParoisseResponse.fromJson(Map<String, dynamic> json) {
    content = json['content'] != null
        ? (json['content'] as List)
        .map((i) => ContentParoisse.fromJson(i))
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

class ContentParoisse {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? description;
  TypeContent? type;

  ContentParoisse({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.name,
    this.description,
    this.type,
  });

  ContentParoisse.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    description = json['description'];
    type = json['type'] != null
        ? TypeContent.fromJson(json['type'])
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
    data['description'] = description;
    data['type'] = type?.toJson();
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

