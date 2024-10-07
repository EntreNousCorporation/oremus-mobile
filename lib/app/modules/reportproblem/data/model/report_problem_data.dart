import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/remote/to_json_interface.dart';

class ReportProblemTypeData {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? code;
  Name? name;

  ReportProblemTypeData({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.code,
    this.name,
  });

  ReportProblemTypeData.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    code = json['code'];
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['code'] = code;
    if (name != null) {
      data['name'] = name!.toJson();
    }
    return data;
  }
}

class ReportProblemData extends ToJsonInterface {
  dynamic reportProblemTypeId;
  dynamic worshipPlaceId;
  String? description;
  String? email;

  ReportProblemData({
    this.reportProblemTypeId,
    this.worshipPlaceId,
    this.description,
    this.email,
  });

  ReportProblemData.fromJson(Map<String, dynamic> json) {
    reportProblemTypeId = json['reportProblemTypeId'];
    worshipPlaceId = json['worshipPlaceId'];
    description = json['description'];
    email = json['email'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reportProblemTypeId'] = reportProblemTypeId;
    data['worshipPlaceId'] = worshipPlaceId;
    data['description'] = description;
    data['email'] = email;
    return data;
  }
}
