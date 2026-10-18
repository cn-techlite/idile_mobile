import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/features/auth/domain/repositories/idile_auth_repository.dart';

final class SessionUseCases {
  const SessionUseCases(this._repository);

  final IdileAuthRepository _repository;

  Future<UserProfile?> restoreSession() => _repository.restoreSession();

  Future<UserProfile> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) => _repository.login(
    email: email,
    password: password,
    rememberMe: rememberMe,
  );

  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) => _repository.register(name: name, email: email, password: password);

  Future<void> logout() => _repository.logout();

  Future<void> forgotPassword(String email) =>
      _repository.forgotPassword(email);

  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) => _repository.verifyResetCode(email: email, code: code);

  Future<void> resetPassword({
    required String resetToken,
    required String password,
  }) => _repository.resetPassword(resetToken: resetToken, password: password);
}
