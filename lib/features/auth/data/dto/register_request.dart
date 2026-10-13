class RegisterRequest {
  final String? email;
  final String? name;
  final String? password;
  final String? phoneNo;

  RegisterRequest({this.email, this.name, this.password, this.phoneNo});

  RegisterRequest copyWith({
    String? email,
    String? name,
    String? password,
    String? phoneNo,
  }) => RegisterRequest(
    email: email ?? this.email,
    name: name ?? this.name,
    password: password ?? this.password,
    phoneNo: phoneNo ?? this.phoneNo,
  );

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        email: json["email"],
        name: json["name"],
        password: json["password"],
        phoneNo: json["phoneNo"],
      );

  Map<String, dynamic> toJson() => {
    "email": email,
    "name": name,
    "password": password,
    "phoneNo": phoneNo,
  };
}
