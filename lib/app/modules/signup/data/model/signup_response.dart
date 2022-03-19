class SignupResponse {
  String? accessToken;
  dynamic expiredAt;

  SignupResponse({
    this.accessToken,
    this.expiredAt,
  });

  SignupResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    expiredAt = json['expiredAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['expiredAt'] = expiredAt;
    return data;
  }
}
