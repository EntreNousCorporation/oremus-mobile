import 'package:oremusapp/app/modules/profile/data/model/profile.dart';

class PlaceType {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? code;
  Translate? translate;

  PlaceType({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.code,
    this.translate,
  });

  PlaceType.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
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
    data['code'] = code;
    data['translate'] = translate?.toJson();
    return data;
  }
}