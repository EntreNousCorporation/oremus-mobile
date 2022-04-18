class OtpResponse {
  String? email;
  String? otp;
  String? status;

  OtpResponse({
    this.email,
    this.otp,
    this.status,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
    email: json["email"],
    otp: json["otp"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
    "status": status,
  };
}