class SigninResponse {
  String? accessToken;
  String? refreshToken;
  dynamic expiredAt;
  dynamic expiresIn;
  bool? isBoUser;
  bool? isTmpPassword;

  SigninResponse({
    this.accessToken,
    this.refreshToken,
    this.expiredAt,
    this.expiresIn,
    this.isBoUser,
    this.isTmpPassword,
  });

  SigninResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    expiredAt = json['expiredAt'];
    expiresIn = json['expiresIn'];
    isBoUser = json['isBoUser'];
    isTmpPassword = json['isTmpPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['expiredAt'] = expiredAt;
    data['expiresIn'] = expiresIn;
    data['isBoUser'] = isBoUser;
    data['isTmpPassword'] = isTmpPassword;
    return data;
  }
}
