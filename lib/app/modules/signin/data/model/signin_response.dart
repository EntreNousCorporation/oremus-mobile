class SigninResponse {
  String? accessToken;
  dynamic expiredAt;
  bool? isBoUser;

  SigninResponse({
    this.accessToken,
    this.expiredAt,
    this.isBoUser,
  });

  SigninResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    expiredAt = json['expiredAt'];
    isBoUser = json['isBoUser'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['expiredAt'] = expiredAt;
    data['isBoUser'] = isBoUser;
    return data;
  }
}
