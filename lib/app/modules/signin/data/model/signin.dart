class Signin {

  String? id;
  String? profile;

  //LOGIN
  String? username;
  String? password;
  String? oldPassword;
  String? newPassword;

  //SIGNUP
  String? phone;
  String? firstname;
  String? lastname;
  String? email;

  Signin({
    this.id,
    this.username,
    this.profile,
    this.password,
    this.oldPassword,
    this.newPassword,
    this.phone,
    this.firstname,
    this.lastname,
    this.email,
  });

  factory Signin.fromJson(Map<String, dynamic> json) => Signin(
    id: json["id"],
    profile: json["profile"],
    username: json["username"],
    password: json["password"],
    oldPassword: json["oldPassword"],
    newPassword: json["newPassword"],
    phone: json["phone"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "profile": profile,
    "username": username,
    "password": password,
    "oldPassword": oldPassword,
    "newPassword": newPassword,
    "phone": phone,
    "firstname": firstname,
    "lastname": lastname,
    "email": email,
  };
}
