class Signin {
  String? username;
  String? password;

  Signin({
    this.username,
    this.password,
  });

  factory Signin.fromJson(Map<String, dynamic> json) => Signin(
    username: json["username"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
  };
}
