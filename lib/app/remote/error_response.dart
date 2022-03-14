class ErrorResponse {
  ErrorResponse({
    this.status,
    this.debugMessage,
    this.path,
    this.requestor,
    this.errors,
    this.timestamp,
  });

  String? status;
  String? debugMessage;
  String? path;
  Requestor? requestor;
  List<Error>? errors;
  String? timestamp;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
    status: json["status"],
    debugMessage: json["debugMessage"],
    path: json["path"],
    requestor: Requestor.fromJson(json["requestor"]),
    errors: List<Error>.from(json["errors"].map((x) => Error.fromJson(x))),
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "debugMessage": debugMessage,
    "path": path,
    "requestor": requestor?.toJson(),
    "errors": List<dynamic>.from(errors?.map((x) => x.toJson()) ?? []),
    "timestamp": timestamp,
  };
}

class Error {
  Error({
    this.code,
    this.field,
    this.defaultMessage,
    this.rejectValue,
  });

  String? code;
  String? field;
  String? defaultMessage;
  RejectValue? rejectValue;

  factory Error.fromJson(Map<String, dynamic> json) => Error(
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

  factory RejectValue.fromJson(Map<String, dynamic> json) => RejectValue(
  );

  Map<String, dynamic> toJson() => {
  };
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
