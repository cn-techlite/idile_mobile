// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/errors/error_handling.dart';
import 'package:idile_mobile_app/core/network/api_exception.dart';
import 'package:idile_mobile_app/core/services/globals.dart';
import 'package:idile_mobile_app/core/services/offline_cache_service.dart';
import 'package:idile_mobile_app/features/auth/data/dto/register_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/resend_code_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/reset_password_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/verify_email_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/update_profile_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/wallet_request.dart';
import 'package:idile_mobile_app/features/auth/data/model/auth_result_model.dart';
import 'package:idile_mobile_app/features/auth/data/model/device_binding_models.dart';
import 'package:idile_mobile_app/features/auth/data/model/login_response_model.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/device_binding_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/push_token_registration_service.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _remoteService;
  final SocialAuthService _socialAuthService;
  final AuthLocalStorageService _localStorageService;
  final AuthSessionService _sessionService;
  final DeviceBindingService _deviceBindingService;
  final PushTokenRegistrationService _pushTokenRegistration;

  AuthRepositoryImpl({
    required AuthRemoteService remoteService,
    required SocialAuthService socialAuthService,
    required AuthLocalStorageService localStorageService,
    required AuthSessionService sessionService,
    required DeviceBindingService deviceBindingService,
    required PushTokenRegistrationService pushTokenRegistration,
  }) : _remoteService = remoteService,
       _socialAuthService = socialAuthService,
       _localStorageService = localStorageService,
       _sessionService = sessionService,
       _deviceBindingService = deviceBindingService,
       _pushTokenRegistration = pushTokenRegistration;

  @override
  Future<AuthResultModel> register({required RegisterRequest request}) async {
    final response = await _remoteService.register(request);
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Registration successful",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final proof = await _signedChallenge();
      final result = await _remoteService.deviceLogin(
        email: email,
        password: password,
        device: proof.device,
        challenge: proof.challenge,
        signature: proof.signature,
      );
      if (result.requiresApproval) {
        return AuthResultModel.deviceApprovalRequired(
          deviceId: result.deviceId,
        );
      }
      return await _completeDeviceSignIn(
        result,
        password: password,
        remember: rememberMe,
      );
    } catch (error) {
      return AuthResultModel.failure(_authErrorMessage(error));
    }
  }

  @override
  Future<AuthResultModel> signInWithGoogle() async {
    try {
      final credential = await _socialAuthService.getGoogleIdToken();
      final proof = await _signedChallenge();
      final result = await _remoteService.deviceGoogle(
        credential: credential,
        device: proof.device,
        challenge: proof.challenge,
        signature: proof.signature,
      );
      if (result.requiresApproval) {
        return AuthResultModel.deviceApprovalRequired(
          deviceId: result.deviceId,
        );
      }
      return await _completeDeviceSignIn(result, social: true);
    } on SocialAuthCancelledException {
      return AuthResultModel.cancelled();
    } catch (e) {
      return AuthResultModel.failure(_authErrorMessage(e));
    }
  }

  @override
  Future<AuthResultModel> approveDevice({
    required String deviceId,
    required String code,
  }) async {
    try {
      final challenge = await _remoteService.getDeviceChallenge();
      final signature = await _deviceBindingService.signChallenge(
        challenge.challenge,
      );
      final result = await _remoteService.approveDevice(
        deviceId: deviceId,
        code: code,
        challenge: challenge.challenge,
        signature: signature,
      );
      return await _completeDeviceSignIn(result);
    } catch (error) {
      return AuthResultModel.failure(_authErrorMessage(error));
    }
  }

  @override
  Future<AuthResultModel> reportUnrecognisedDevice(String token) async {
    try {
      await _remoteService.reportUnrecognisedDevice(token);
      return AuthResultModel.success(message: 'The device has been revoked.');
    } catch (error) {
      return AuthResultModel.failure(_authErrorMessage(error));
    }
  }

  @override
  Future<AuthResultModel> signInWithApple() async {
    try {
      final apple = await _socialAuthService.getAppleCredential();
      final proof = await _signedChallenge();
      final result = await _remoteService.deviceApple(
        apple: apple,
        device: proof.device,
        challenge: proof.challenge,
        signature: proof.signature,
      );
      if (result.requiresApproval) {
        return AuthResultModel.deviceApprovalRequired(
          deviceId: result.deviceId,
        );
      }
      return await _completeDeviceSignIn(result, social: true);
    } on SocialAuthCancelledException {
      return AuthResultModel.cancelled();
    } catch (error) {
      return AuthResultModel.failure(_authErrorMessage(error));
    }
  }

  @override
  Future<AuthResultModel> verifyEmail({
    required String token,
    required String password,
  }) async {
    final response = await _remoteService.verifyEmail(
      VerifyEmailRequest(token: token, password: password),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final model = LoginResponseModel.fromJson(jsonDecode(response.body));
      await _localStorageService.saveVerifiedEmailSession(
        model: model,
        password: password,
      );
      await _sessionService.initialize();
      await registerPushToken();

      return AuthResultModel.success(loginData: model);
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> sendVerificationCode({required String email}) async {
    final response = await _remoteService.sendVerificationCode(
      ResendCodeRequest(email: email),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Verification code sent",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> resendPasswordCode({required String email}) async {
    final response = await _remoteService.resendPasswordCode(
      ResendCodeRequest(email: email),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Password reset code sent",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final resetToken = await _remoteService.verifyPasswordResetCode(
        email: email,
        code: code,
      );
      if (resetToken.trim().isEmpty || resetToken == 'null') {
        return AuthResultModel.failure('Invalid or expired reset code');
      }
      return AuthResultModel.success(
        rawData: resetToken,
        message: 'Reset code verified',
      );
    } catch (error) {
      return AuthResultModel.failure(error.toString());
    }
  }

  @override
  Future<AuthResultModel> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    final response = await _remoteService.resetPassword(
      ResetPasswordRequest(resetToken: resetToken, password: password),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Password updated successfully",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> updateProfile({
    required UpdateProfileRequest request,
  }) async {
    final response = await _remoteService.updateProfile(request);
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      await setToLocalStorage(name: 'InfoCompleted', data: 'Completed');
      return AuthResultModel.success(
        rawData: response.body,
        message: 'Profile updated successfully',
      );
    }
    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> createWallet({required WalletRequest request}) async {
    final response = await _remoteService.createWallet(request);
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      await setBoolToLocalStorage(name: 'walletUser', data: true);
      await _sessionService.initialize();
      return AuthResultModel.success(
        rawData: response.body,
        message: 'Wallet created successfully',
      );
    }
    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<void> registerPushToken() async {
    try {
      await _pushTokenRegistration.registerStoredToken(force: true);
    } catch (e) {
      printData("registerPushToken", e.toString());
    }
  }

  @override
  Future<AuthResultModel> logout() async {
    try {
      await _sessionService.initialize();

      try {
        await _pushTokenRegistration.remove();
      } catch (error) {
        printData('removePushToken', error.toString());
      }
      await _remoteService.logoutSession();

      await _socialAuthService.signOutSocials();
      await _localStorageService.clearAuthSession();
      await _sessionService.clear();
      await OfflineCacheService.clear();

      return AuthResultModel.success(message: "Logged out successfully");
    } catch (e) {
      return AuthResultModel.failure(e.toString());
    }
  }

  @override
  Future<AuthResultModel> refreshTokens() async {
    try {
      await _sessionService.initialize();

      final refreshToken = globals.refreshToken.trim();

      if (refreshToken.isEmpty) {
        return AuthResultModel.failure("No saved session to refresh");
      }

      final tokens = await _remoteService.refreshSessionTokens(refreshToken);
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        return AuthResultModel.failure(
          'The refresh response did not contain both tokens',
        );
      }
      final model = LoginResponseModel.fromJson({
        'accessToken': tokens.accessToken,
        'refreshToken': tokens.refreshToken,
      });
      await _localStorageService.saveRefreshedTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _sessionService.initialize();
      return AuthResultModel.success(loginData: model);
    } catch (e) {
      return AuthResultModel.failure(e.toString());
    }
  }

  Future<_SignedDeviceChallenge> _signedChallenge() async {
    final device = await _deviceBindingService.getDeviceInfo();
    final challenge = await _remoteService.getDeviceChallenge();
    if (challenge.expiresAt.isBefore(DateTime.now().toUtc())) {
      throw const DeviceBindingException(
        'The device challenge expired. Please try again.',
      );
    }
    final signature = await _deviceBindingService.signChallenge(
      challenge.challenge,
    );
    return _SignedDeviceChallenge(
      device: device,
      challenge: challenge.challenge,
      signature: signature,
    );
  }

  Future<AuthResultModel> _completeDeviceSignIn(
    DeviceSignInResult result, {
    String? password,
    bool remember = true,
    bool social = false,
  }) async {
    if (!result.isSignedIn) {
      return AuthResultModel.failure('The device could not be signed in.');
    }
    await _remoteService.saveDeviceBoundSession(result);
    final model = LoginResponseModel.fromJson({
      'accessToken': result.accessToken,
      'refreshToken': result.refreshToken,
      'remember': remember,
    });
    if (social) {
      await _localStorageService.saveSocialLoginSession(
        model: model,
        providerUid: model.userId ?? '',
      );
    } else {
      await _localStorageService.saveLoginSession(
        model: model,
        password: password,
      );
    }
    await _sessionService.initialize();
    await registerPushToken();
    return AuthResultModel.success(loginData: model);
  }

  String _authErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    if (error is DeviceBindingException) return error.message;
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}

class _SignedDeviceChallenge {
  const _SignedDeviceChallenge({
    required this.device,
    required this.challenge,
    required this.signature,
  });

  final DeviceInfo device;
  final String challenge;
  final String signature;
}
