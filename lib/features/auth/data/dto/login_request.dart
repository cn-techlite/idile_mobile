class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest copyWith({String? email, String? password, bool? rememberMe}) =>
      LoginRequest(
        email: email ?? this.email,
        password: password ?? this.password,
        rememberMe: rememberMe ?? this.rememberMe,
      );

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    email: json['email'] as String,
    password: json['password'] as String,
    rememberMe: json['rememberMe'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'rememberMe': rememberMe,
  };
}
