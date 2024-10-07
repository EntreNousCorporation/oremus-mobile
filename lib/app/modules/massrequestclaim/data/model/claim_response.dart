import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/remote/to_json_interface.dart';

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

class ClaimData extends ToJsonInterface {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? description;
  String? observation;
  String? reasonForRejection;
  TypeOfClaim? typeOfClaim;
  MassRequest? massRequest;
  TypeOfClaim? status;

  ClaimData({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.description,
    this.observation,
    this.reasonForRejection,
    this.typeOfClaim,
    this.massRequest,
    this.status,
  });

  ClaimData.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    description = json['description'];
    observation = json['observation'];
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

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['description'] = description;
    data['observation'] = observation;
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

  TypeOfClaim({
    this.code,
    this.name,
  });

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
  Profile? user;

  MassRequest({
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
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
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
      data['status'] = status?.toJson();
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
  Typee? type;
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
    type = json['type'] != null ? Typee.fromJson(json['type']) : null;
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
