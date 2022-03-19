class Signin {

  //LOGIN
  String? username;
  String? password;

  //SIGNUP
  String? phone;
  String? firstname;
  String? lastname;

  Signin({
    this.username,
    this.password,
    this.phone,
    this.firstname,
    this.lastname,
  });

  factory Signin.fromJson(Map<String, dynamic> json) => Signin(
    username: json["username"],
    password: json["password"],
    phone: json["phone"],
    firstname: json["firstname"],
    lastname: json["lastname"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "phone": phone,
    "firstname": firstname,
    "lastname": lastname,
  };
}
