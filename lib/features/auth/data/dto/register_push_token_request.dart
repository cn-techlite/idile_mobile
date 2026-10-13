class RegisterPushTokenRequest {
  const RegisterPushTokenRequest({required this.token});

  final String token;

  Map<String, dynamic> toJson() => {'token': token};
}
