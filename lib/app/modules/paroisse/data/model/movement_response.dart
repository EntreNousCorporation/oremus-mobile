import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';

class MovementResponse {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? description;
  String? meetingPlace;
  String? leader;
  Contact? contact;
  Chaplain? chaplain;
  List<OpeningTime>? openingTime;

  MovementResponse({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.name,
    this.description,
    this.meetingPlace,
    this.leader,
    this.contact,
    this.chaplain,
    this.openingTime,
  });

  MovementResponse.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    description = json['description'];
    meetingPlace = json['meetingPlace'];
    leader = json['leader'];
    contact =
        json['contact'] != null ? Contact.fromJson(json['contact']) : null;
    chaplain =
        json['chaplain'] != null ? Chaplain.fromJson(json['chaplain']) : null;
    openingTime = json['openingTime'] != null
        ? (json['openingTime'] as List)
            .map((i) => OpeningTime.fromJson(i))
            .toList()
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
    data['meetingPlace'] = meetingPlace;
    data['leader'] = leader;
    data['contact'] = contact?.toJson();
    data['chaplain'] = chaplain?.toJson();
    if (openingTime != null) {
      data['openingTime'] = openingTime?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Contact {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? fax;
  String? url;
  List<String>? emails;
  List<String>? numbers;

  Contact({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.name,
    this.fax,
    this.url,
    this.emails,
    this.numbers,
  });

  Contact.fromJson(Map<String, dynamic> json) {
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

class Chaplain {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? firstname;
  String? email;
  String? lastname;
  bool? isEnabled;
  String? type;
  Role? role;

  Chaplain({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.firstname,
    this.email,
    this.lastname,
    this.isEnabled,
    this.type,
    this.role,
  });

  Chaplain.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    firstname = json['firstname'];
    email = json['email'];
    lastname = json['lastname'];
    isEnabled = json['isEnabled'];
    type = json['type'];
    role = json['role'] != null ? Role.fromJson(json['role']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['firstname'] = firstname;
    data['email'] = email;
    data['lastname'] = lastname;
    data['isEnabled'] = isEnabled;
    data['type'] = type;
    data['role'] = role?.toJson();
    return data;
  }
}
