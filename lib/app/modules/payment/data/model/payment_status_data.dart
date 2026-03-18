import 'package:oremusapp/app/remote/to_json_interface.dart';

class PaymentStatusData {
  dynamic id;
  String? transactionId;
  String? paymentStatus;

  PaymentStatusData({
    this.id,
    this.transactionId,
    this.paymentStatus,
  });

  PaymentStatusData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionId = json['transactionId'];
    paymentStatus = json['paymentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transactionId'] = transactionId;
    data['paymentStatus'] = paymentStatus;
    return data;
  }
}

class PaymentMethodData extends ToJsonInterface {
  String? code;
  Name? name;

  PaymentMethodData({this.code, this.name});

  PaymentMethodData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name =
    json['name'] != null ? Name.fromJson(json['name']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (name != null) {
      data['name'] = name?.toJson();
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

  Name({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.fr,
    this.en,
  });

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