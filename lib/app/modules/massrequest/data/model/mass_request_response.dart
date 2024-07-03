import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';

class MassRequestResponse {
  List<MassRequestData>? content;
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

  MassRequestResponse({
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

  MassRequestResponse.fromJson(Map<String, dynamic> json) {
    content = json['content'] != null
        ? (json['content'] as List)
            .map((i) => MassRequestData.fromJson(i))
            .toList()
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

class MassRequestData {
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
  Status? status;
  Status? typeOfMassRequest;
  User? user;

  MassRequestData({
    this.identifier,
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
    this.user,
  });

  MassRequestData.fromJson(Map<String, dynamic> json) {
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
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
    typeOfMassRequest = json['typeOfMassRequest'] != null
        ? Status.fromJson(json['typeOfMassRequest'])
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
      data['worshipPlace'] = worshipPlace?.toJson();
    }
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (typeOfMassRequest != null) {
      data['typeOfMassRequest'] = typeOfMassRequest?.toJson();
    }
    if (user != null) {
      data['user'] = user?.toJson();
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

  WorshipPlace({
    this.identifier,
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
    this.coverImage,
  });

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
      data['type'] = type?.toJson();
    }
    data['description'] = description;
    if (address != null) {
      data['address'] = address?.toJson();
    }
    if (diocese != null) {
      data['diocese'] = diocese?.toJson();
    }
    data['parent'] = parent;
    if (localisation != null) {
      data['localisation'] = localisation?.toJson();
    }
    if (coverImage != null) {
      data['coverImage'] = coverImage?.toJson();
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
  Translate? translate;

  Type({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.code,
    this.translate,
  });

  Type.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    code = json['code'];
    translate = json['translate'] != null
        ? Translate.fromJson(json['translate'])
        : null;
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

class Translate {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? fr;
  String? en;

  Translate({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.fr,
    this.en,
  });

  Translate.fromJson(Map<String, dynamic> json) {
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

class Status {
  String? code;
  Translate? name;

  Status({this.code, this.name});

  Status.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'] != null ? Translate.fromJson(json['name']) : null;
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

  User({
    this.identifier,
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
    this.contacts,
  });

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
      data['role'] = role?.toJson();
    }
    data['isBoUser'] = isBoUser;
    if (contacts != null) {
      data['contacts'] = contacts?.map((v) => v.toJson()).toList();
    }
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
      this.numbers});

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
