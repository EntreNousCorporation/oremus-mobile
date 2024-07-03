class ClaimRequest {
  String? description;
  dynamic massRequest;
  String? typeOfClaim;

  ClaimRequest({
    this.description,
    this.massRequest,
    this.typeOfClaim,
  });

  ClaimRequest.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    massRequest = json['massRequest'];
    typeOfClaim = json['typeOfClaim'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['massRequest'] = massRequest;
    data['typeOfClaim'] = typeOfClaim;
    return data;
  }
}

class ClaimResponse {
  List<ClaimData>? content;
  Pageable? pageable;
  dynamic totalPages;
  dynamic totalElements;
  bool? last;
  bool? first;
  dynamic numberOfElements;
  Sort? sort;
  dynamic number;
  dynamic size;
  bool? empty;

  ClaimResponse({
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

  ClaimResponse.fromJson(Map<String, dynamic> json) {
    content = json['content'] != null
        ? (json['content'] as List).map((i) => ClaimData.fromJson(i)).toList()
        : null;
    pageable =
        json['pageable'] != null ? Pageable.fromJson(json['pageable']) : null;
    totalPages = json['totalPages'];
    last = json['last'];
    first = json['first'];
    numberOfElements = json['numberOfElements'];
    sort = json['sort'] != null ? Sort.fromJson(json['sort']) : null;
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
  dynamic pageNumber;
  dynamic pageSize;
  dynamic offset;
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
    sort = json['sort'] != null ? Sort.fromJson(json['sort']) : null;
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

class ClaimData {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? description;
  String? reasonForRejection;
  TypeOfClaim? typeOfClaim;
  MassRequest? massRequest;
  TypeOfClaim? status;

  ClaimData(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.description,
      this.reasonForRejection,
      this.typeOfClaim,
      this.massRequest,
      this.status});

  ClaimData.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    description = json['description'];
    reasonForRejection = json['reasonForRejection'];
    typeOfClaim = json['typeOfClaim'] != null
        ? TypeOfClaim.fromJson(json['typeOfClaim'])
        : null;
    massRequest = json['massRequest'] != null
        ? MassRequest.fromJson(json['massRequest'])
        : null;
    status =
        json['status'] != null ? TypeOfClaim.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['description'] = description;
    data['reasonForRejection'] = reasonForRejection;
    if (typeOfClaim != null) {
      data['typeOfClaim'] = typeOfClaim!.toJson();
    }
    if (massRequest != null) {
      data['massRequest'] = massRequest!.toJson();
    }
    if (status != null) {
      data['status'] = status!.toJson();
    }
    return data;
  }
}

class TypeOfClaim {
  String? code;
  Name? name;

  TypeOfClaim({this.code, this.name});

  TypeOfClaim.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (name != null) {
      data['name'] = name!.toJson();
    }
    return data;
  }
}

class Name {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? fr;
  String? en;

  Name(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.fr,
      this.en});

  Name.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    fr = json['fr'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['fr'] = fr;
    data['en'] = en;
    return data;
  }
}

class MassRequest {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? startDate;
  String? traceId;
  dynamic price;
  String? endDate;
  String? prayerIntent;
  WorshipPlace? worshipPlace;
  TypeOfClaim? status;
  TypeOfClaim? typeOfMassRequest;
  User? user;

  MassRequest(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.startDate,
      this.traceId,
      this.price,
      this.endDate,
      this.prayerIntent,
      this.worshipPlace,
      this.status,
      this.typeOfMassRequest,
      this.user});

  MassRequest.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    startDate = json['startDate'];
    traceId = json['traceId'];
    price = json['price'];
    endDate = json['endDate'];
    prayerIntent = json['prayerIntent'];
    worshipPlace = json['worshipPlace'] != null
        ? WorshipPlace.fromJson(json['worshipPlace'])
        : null;
    status =
        json['status'] != null ? TypeOfClaim.fromJson(json['status']) : null;
    typeOfMassRequest = json['typeOfMassRequest'] != null
        ? TypeOfClaim.fromJson(json['typeOfMassRequest'])
        : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['startDate'] = startDate;
    data['traceId'] = traceId;
    data['price'] = price;
    data['endDate'] = endDate;
    data['prayerIntent'] = prayerIntent;
    if (worshipPlace != null) {
      data['worshipPlace'] = worshipPlace!.toJson();
    }
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (typeOfMassRequest != null) {
      data['typeOfMassRequest'] = typeOfMassRequest!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class WorshipPlace {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? massInfo;
  dynamic massRequestPrice;
  String? status;
  Type? type;
  String? description;
  Address? address;
  Diocese? diocese;
  String? parent;
  Localisation? localisation;
  CoverImage? coverImage;

  WorshipPlace(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.name,
      this.massInfo,
      this.massRequestPrice,
      this.status,
      this.type,
      this.description,
      this.address,
      this.diocese,
      this.parent,
      this.localisation,
      this.coverImage});

  WorshipPlace.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    massInfo = json['massInfo'];
    massRequestPrice = json['massRequestPrice'];
    status = json['status'];
    type = json['type'] != null ? Type.fromJson(json['type']) : null;
    description = json['description'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    diocese =
        json['diocese'] != null ? Diocese.fromJson(json['diocese']) : null;
    parent = json['parent'];
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
    data['massInfo'] = massInfo;
    data['massRequestPrice'] = massRequestPrice;
    data['status'] = status;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['description'] = description;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (diocese != null) {
      data['diocese'] = diocese!.toJson();
    }
    data['parent'] = parent;
    if (localisation != null) {
      data['localisation'] = localisation!.toJson();
    }
    if (coverImage != null) {
      data['coverImage'] = coverImage!.toJson();
    }
    return data;
  }
}

class Type {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? code;
  Name? translate;

  Type(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.code,
      this.translate});

  Type.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    code = json['code'];
    translate =
        json['translate'] != null ? Name.fromJson(json['translate']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['code'] = code;
    if (translate != null) {
      data['translate'] = translate!.toJson();
    }
    return data;
  }
}

class Address {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? municipality;
  String? city;
  String? neighbourhood;

  Address(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.name,
      this.municipality,
      this.city,
      this.neighbourhood});

  Address.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
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
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
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
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? status;
  String? leader;
  bool? isArchDiocese;

  Diocese(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.name,
      this.status,
      this.leader,
      this.isArchDiocese});

  Diocese.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    status = json['status'];
    leader = json['leader'];
    isArchDiocese = json['isArchDiocese'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['status'] = status;
    data['leader'] = leader;
    data['isArchDiocese'] = isArchDiocese;
    return data;
  }
}

class Localisation {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  dynamic longitude;
  dynamic latitude;

  Localisation(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.longitude,
      this.latitude});

  Localisation.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}

class CoverImage {
  String? name;
  String? link;

  CoverImage({this.name, this.link});

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

class User {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? phone;
  String? firstname;
  String? email;
  String? lastname;
  bool? isEnabled;
  String? type;
  Role? role;
  bool? isBoUser;
  List<Contacts>? contacts;

  User(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.phone,
      this.firstname,
      this.email,
      this.lastname,
      this.isEnabled,
      this.type,
      this.role,
      this.isBoUser,
      this.contacts});

  User.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    phone = json['phone'];
    firstname = json['firstname'];
    email = json['email'];
    lastname = json['lastname'];
    isEnabled = json['isEnabled'];
    type = json['type'];
    role = json['role'] != null ? Role.fromJson(json['role']) : null;
    isBoUser = json['isBoUser'];
    if (json['contacts'] != null) {
      contacts = <Contacts>[];
      json['contacts'].forEach((v) {
        contacts!.add(Contacts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['phone'] = phone;
    data['firstname'] = firstname;
    data['email'] = email;
    data['lastname'] = lastname;
    data['isEnabled'] = isEnabled;
    data['type'] = type;
    if (role != null) {
      data['role'] = role!.toJson();
    }
    data['isBoUser'] = isBoUser;
    if (contacts != null) {
      data['contacts'] = contacts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Role {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? code;
  Name? translate;
  List<Functionalities>? functionalities;

  Role(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.code,
      this.translate,
      this.functionalities});

  Role.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    code = json['code'];
    translate =
        json['translate'] != null ? Name.fromJson(json['translate']) : null;
    if (json['functionalities'] != null) {
      functionalities = <Functionalities>[];
      json['functionalities'].forEach((v) {
        functionalities!.add(Functionalities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['code'] = code;
    if (translate != null) {
      data['translate'] = translate!.toJson();
    }
    if (functionalities != null) {
      data['functionalities'] =
          functionalities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Functionalities {
  int? identifier;
  String? code;

  Functionalities({this.identifier, this.code});

  Functionalities.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['code'] = code;
    return data;
  }
}

class Contacts {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? fax;
  List<String>? emails;
  List<String>? numbers;

  Contacts(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.name,
      this.fax,
      this.emails,
      this.numbers,});

  Contacts.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    fax = json['fax'];
    emails = json['emails'].cast<String>();
    numbers = json['numbers'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['fax'] = fax;
    data['emails'] = emails;
    data['numbers'] = numbers;
    return data;
  }
}
