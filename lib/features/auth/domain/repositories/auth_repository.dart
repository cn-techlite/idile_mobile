import 'package:idile_mobile_app/features/auth/domain/parameters/register_request.dart';
import 'package:idile_mobile_app/features/auth/domain/entities/auth_result.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/update_profile_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/wallet_request.dart';

abstract class AuthRepository {
  Future<AuthResultModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<AuthResultModel> register({required RegisterRequest request});

  Future<AuthResultModel> signInWithGoogle();
  Future<AuthResultModel> signInWithApple();

  Future<AuthResultModel> approveDevice({
    required String deviceId,
    required String code,
  });

  Future<AuthResultModel> reportUnrecognisedDevice(String token);

  Future<AuthResultModel> verifyEmail({
    required String token,
    required String password,
  });

  Future<AuthResultModel> sendVerificationCode({required String email});

  Future<AuthResultModel> resendPasswordCode({required String email});

  Future<AuthResultModel> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  Future<AuthResultModel> resetPassword({
    required String resetToken,
    required String password,
  });

  Future<AuthResultModel> updateProfile({
    required UpdateProfileRequest request,
  });
  Future<AuthResultModel> createWallet({required WalletRequest request});
  Future<void> registerPushToken();
  Future<AuthResultModel> logout();
  Future<AuthResultModel> refreshTokens();
}
