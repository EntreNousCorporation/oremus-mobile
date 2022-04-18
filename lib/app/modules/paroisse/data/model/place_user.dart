import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';

class PlaceUser {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? phone;
  String? firstname;
  String? lastname;
  bool? isEnabled;
  String? type;
  String? email;
  Role? role;
  List<Contact>? contacts;

  PlaceUser({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.phone,
    this.firstname,
    this.lastname,
    this.isEnabled,
    this.type,
    this.email,
    this.role,
    this.contacts,
  });

  PlaceUser.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    phone = json['phone'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    isEnabled = json['isEnabled'];
    type = json['type'];
    email = json['email'];
    role = json['role'] != null
        ? Role.fromJson(json['role'])
        : null;
    contacts = json['contacts'] != null
        ? (json['contacts'] as List)
        .map((i) => Contact.fromJson(i))
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
    data['phone'] = phone;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['isEnabled'] = isEnabled;
    data['type'] = type;
    data['email'] = email;
    data['role'] = role?.toJson();
    if (contacts != null) {
      data['contacts'] = contacts?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
