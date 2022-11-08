class ErrorResponse {
  String? status;
  String? debugMessage;
  String? path;
  Requestor? requestor;
  ErrorDetail? errors;
  String? timestamp;

  ErrorResponse({
    this.status,
    this.debugMessage,
    this.path,
    this.requestor,
    this.errors,
    this.timestamp,
  });

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    debugMessage = json['debugMessage'];
    path = json['path'];
    requestor = json['requestor'] != null
        ? Requestor.fromJson(json['requestor'])
        : null;
    errors = json['errors'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['debugMessage'] = debugMessage;
    data['path'] = path;
    if (requestor != null) {
      data['requestor'] = requestor!.toJson();
    }
    data['errors'] = errors;
    data['timestamp'] = timestamp;
    return data;
  }
}

class ErrorDetail {
  ErrorDetail({
    this.code,
    this.field,
    this.defaultMessage,
    this.rejectValue,
  });

  String? code;
  String? field;
  String? defaultMessage;
  RejectValue? rejectValue;

  factory ErrorDetail.fromJson(Map<String, dynamic> json) => ErrorDetail(
        code: json["code"],
        field: json["field"],
        defaultMessage: json["defaultMessage"],
        rejectValue: RejectValue.fromJson(json["rejectValue"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "field": field,
        "defaultMessage": defaultMessage,
        "rejectValue": rejectValue?.toJson(),
      };
}

class RejectValue {
  RejectValue();

  factory RejectValue.fromJson(Map<String, dynamic> json) => RejectValue();

  Map<String, dynamic> toJson() => {};
}

class Requestor {
  Requestor({
    this.serverName,
    this.remoteUser,
    this.requestedSessionId,
  });

  String? serverName;
  String? remoteUser;
  String? requestedSessionId;

  factory Requestor.fromJson(Map<String, dynamic> json) => Requestor(
        serverName: json["serverName"],
        remoteUser: json["remoteUser"],
        requestedSessionId: json["requestedSessionId"],
      );

  Map<String, dynamic> toJson() => {
        "serverName": serverName,
        "remoteUser": remoteUser,
        "requestedSessionId": requestedSessionId,
      };
}
