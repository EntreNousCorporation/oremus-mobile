class Connection {
  String? username;
  String? password;

  Connection({
    this.username,
    this.password,
  });

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
    username: json["username"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
  };
}
