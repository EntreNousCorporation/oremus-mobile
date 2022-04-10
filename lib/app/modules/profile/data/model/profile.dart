class Profile {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? phone;
  String? firstname;
  String? lastname;
  bool? isEnabled;
  String? email;
  Role? role;

  Profile({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.phone,
    this.firstname,
    this.lastname,
    this.isEnabled,
    this.email,
    this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        identifier: json["identifier"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        createdBy: json["createdBy"],
        modifiedBy: json["modifiedBy"],
        phone: json["phone"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        isEnabled: json["isEnabled"],
        email: json["email"],
        role: json['role'] != null ? Role.fromJson(json['role']) : null,
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "phone": phone,
        "firstname": firstname,
        "lastname": lastname,
        "isEnabled": isEnabled,
        "email": email,
        "role": role?.toJson(),
      };
}

class Role {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? code;
  Translate? translate;
  List<Functionality>? functionalities;
  String? lastname;
  bool? isEnabled;
  bool? email;

  Role({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.code,
    this.translate,
    this.functionalities,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        identifier: json["identifier"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        code: json["code"],
        translate: json['translate'] != null
            ? Translate.fromJson(json['translate'])
            : null,
        functionalities: json['functionalities'] != null
            ? (json['functionalities'] as List)
                .map((i) => Functionality.fromJson(i))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "code": code,
        "translate": translate?.toJson(),
        "functionalities": functionalities != null
            ? functionalities?.map((v) => v.toJson()).toList()
            : [],
      };
}

class Functionality {
  dynamic identifier;
  String? code;

  Functionality({
    this.identifier,
    this.code,
  });

  factory Functionality.fromJson(Map<String, dynamic> json) => Functionality(
        identifier: json["identifier"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "code": code,
      };
}

class Translate {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? fr;
  String? en;

  Translate({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.fr,
    this.en,
  });

  factory Translate.fromJson(Map<String, dynamic> json) => Translate(
        identifier: json["identifier"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        fr: json["fr"],
        en: json["en"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "fr": fr,
        "en": en,
      };
}
