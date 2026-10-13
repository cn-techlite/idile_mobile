class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.resetToken,
    required this.password,
  });

  final String resetToken;
  final String password;

  Map<String, dynamic> toJson() {
    return {'resetToken': resetToken, 'password': password};
  }
}
