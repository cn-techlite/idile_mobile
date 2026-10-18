import 'package:idile_mobile_app/features/auth/domain/entities/auth_result.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/register_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/update_profile_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/wallet_request.dart';
import 'package:idile_mobile_app/features/auth/domain/repositories/auth_repository.dart';

final class AuthUseCases {
  const AuthUseCases(this._repository);

  final AuthRepository _repository;

  Future<AuthResultModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) => _repository.login(
    email: email,
    password: password,
    rememberMe: rememberMe,
  );

  Future<AuthResultModel> register({required RegisterRequest request}) =>
      _repository.register(request: request);

  Future<AuthResultModel> signInWithGoogle() => _repository.signInWithGoogle();

  Future<AuthResultModel> signInWithApple() => _repository.signInWithApple();

  Future<AuthResultModel> approveDevice({
    required String deviceId,
    required String code,
  }) => _repository.approveDevice(deviceId: deviceId, code: code);

  Future<AuthResultModel> reportUnrecognisedDevice(String token) =>
      _repository.reportUnrecognisedDevice(token);

  Future<AuthResultModel> verifyEmail({
    required String token,
    required String password,
  }) => _repository.verifyEmail(token: token, password: password);

  Future<AuthResultModel> sendVerificationCode({required String email}) =>
      _repository.sendVerificationCode(email: email);

  Future<AuthResultModel> resendPasswordCode({required String email}) =>
      _repository.resendPasswordCode(email: email);

  Future<AuthResultModel> verifyPasswordResetCode({
    required String email,
    required String code,
  }) => _repository.verifyPasswordResetCode(email: email, code: code);

  Future<AuthResultModel> resetPassword({
    required String resetToken,
    required String password,
  }) => _repository.resetPassword(resetToken: resetToken, password: password);

  Future<AuthResultModel> updateProfile({
    required UpdateProfileRequest request,
  }) => _repository.updateProfile(request: request);

  Future<AuthResultModel> createWallet({required WalletRequest request}) =>
      _repository.createWallet(request: request);

  Future<void> registerPushToken() => _repository.registerPushToken();

  Future<AuthResultModel> logout() => _repository.logout();

  Future<AuthResultModel> refreshTokens() => _repository.refreshTokens();
}
