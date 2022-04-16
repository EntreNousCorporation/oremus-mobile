import 'package:oremusapp/app/modules/profile/data/model/profile.dart';

class LiturgicalCelebrationResponse {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? description;
  LiturgicalType? type;
  bool? isRecurrent;
  List<OpeningTime>? openingTime;

  LiturgicalCelebrationResponse({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.name,
    this.description,
    this.type,
    this.isRecurrent,
    this.openingTime,
  });

  LiturgicalCelebrationResponse.fromJson(Map<String, dynamic> json) {
    openingTime = json['openingTime'] != null
        ? (json['openingTime'] as List)
        .map((i) => OpeningTime.fromJson(i))
        .toList()
        : null;
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    description = json['description'];
    type = json['type'] != null ? LiturgicalType.fromJson(json['type']) : null;
    isRecurrent = json['isRecurrent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (openingTime != null) {
      data['openingTime'] = openingTime?.map((v) => v.toJson()).toList();
    }
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['description'] = description;
    data['type'] = type?.toJson();
    data['isRecurrent'] = isRecurrent;
    return data;
  }
}


class OpeningTime {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  dynamic dayOfWeek;
  List<Slot>? slots;
  bool? isSelected = false;

  OpeningTime({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.dayOfWeek,
    this.isSelected,
  });

  OpeningTime.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    dayOfWeek = json['dayOfWeek'];
    isSelected = json['isSelected'];
    slots = json['slots'] != null
        ? (json['slots'] as List)
        .map((i) => Slot.fromJson(i))
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
    data['dayOfWeek'] = dayOfWeek;
    data['isSelected'] = isSelected;
    if (slots != null) {
      data['slots'] = slots?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LiturgicalType {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? code;
  Translate? translate;

  LiturgicalType({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.code,
    this.translate,
  });

  LiturgicalType.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    code = json['code'];
    translate = json['translate'] != null ? Translate.fromJson(json['translate']) : null;
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

class Slot {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? startTime;
  String? endTime;

  Slot({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.startTime,
    this.endTime,
  });

  Slot.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    return data;
  }
}