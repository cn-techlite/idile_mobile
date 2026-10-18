import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';

abstract interface class IdileAuthRepository {
  Future<UserProfile?> restoreSession();
  Future<UserProfile> login({
    required String email,
    required String password,
    required bool rememberMe,
  });
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<String> verifyResetCode({required String email, required String code});
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  });
}
