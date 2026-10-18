import 'dart:convert';

import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/constants/api_constants.dart';
import 'package:idile_mobile_app/core/errors/error_handling.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/core/services/globals.dart';
import 'package:idile_mobile_app/features/auth/data/dto/login_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/register_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/resend_code_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/reset_password_request.dart';
import 'package:idile_mobile_app/features/auth/data/dto/verify_email_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/update_profile_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/wallet_request.dart';
import 'package:idile_mobile_app/features/auth/data/model/device_binding_models.dart';
import 'package:idile_mobile_app/features/auth/data/model/apple_sign_in_payload.dart';
import 'package:idile_mobile_app/features/home/domain/entities/hearth/hearth_models.dart';
import 'package:http/http.dart' as http;

class AuthRemoteService {
  AuthRemoteService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Map<String, String> get _headers => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': ApiConstants.userAgent,
  };

  Future<http.Response> register(RegisterRequest request) => _post(
    Endpoints.registerUrl,
    request.toJson(),
    logLabel: 'Register Response',
  );

  Future<http.Response> login(LoginRequest request) =>
      _post(Endpoints.loginUrl, request.toJson(), logLabel: 'Login Data');

  Future<http.Response> verifyEmail(VerifyEmailRequest request) => _post(
    Endpoints.emailVerificationUrl,
    request.toJson(),
    logLabel: 'Verify Email',
  );

  Future<http.Response> sendVerificationCode(ResendCodeRequest request) =>
      _post(
        Endpoints.resendEmailVerificationTokenUrl,
        request.toJson(),
        logLabel: 'Send Email Verification Code Response',
      );

  Future<http.Response> resendPasswordCode(ResendCodeRequest request) => _post(
    Endpoints.forgetPasswordUrl,
    request.toJson(),
    logLabel: 'Request Password Reset Code Response',
  );

  Future<http.Response> resetPassword(ResetPasswordRequest request) => _post(
    Endpoints.resetPasswordUrl,
    request.toJson(),
    logLabel: 'Reset Password Response',
  );

  Future<http.Response> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await http.put(
        Uri.parse('${Endpoints.baseUrl}AuthUsers/update-user'),
        body: jsonEncode(request.toJson()),
        headers: _authorizedHeaders,
      );
      printData('Update Profile Response', response.body);
      return response;
    } catch (error) {
      return Future.error(handleHttpError(error));
    }
  }

  Future<http.Response> createWallet(WalletRequest request) => _post(
    'Wallet/wallet-user',
    request.toJson(),
    authorized: true,
    logLabel: 'Wallet Registration Response',
  );

  Future<http.Response> logout() => _post(
    Endpoints.logoutUrl,
    {'refreshToken': globals.refreshToken},
    authorized: true,
    logLabel: 'Log Out Response',
  );

  Future<http.Response> refreshTokens(String refreshToken) => _post(
    Endpoints.refreshTokenUrl,
    {'refreshToken': refreshToken},
    logLabel: 'Refresh Tokens Response',
  );

  Future<AuthTokens> refreshSessionTokens(String refreshToken) async {
    final isDeviceBound = await _api.store.isDeviceBound;
    final tokens = await _api.post(
      '/${Endpoints.refreshTokenUrl}',
      (value) => AuthTokens.fromJson(Map<String, dynamic>.from(value as Map)),
      body: {'refreshToken': refreshToken},
      auth: false,
      dpop: isDeviceBound,
    );
    await _api.store.save(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  // Typed Idile API methods used by the Home/Bills/Subs/More feature group.
  Future<AuthTokens> loginForSession({
    required String email,
    required String password,
    required bool rememberMe,
  }) => _api.post(
    '/auth/login',
    (value) => AuthTokens.fromJson(Map<String, dynamic>.from(value as Map)),
    body: {'email': email, 'password': password, 'rememberMe': rememberMe},
    auth: false,
  );

  Future<DeviceChallenge> getDeviceChallenge() => _api.post(
    '/${Endpoints.deviceChallengeUrl}',
    (value) =>
        DeviceChallenge.fromJson(Map<String, dynamic>.from(value as Map)),
    auth: false,
  );

  Future<DeviceSignInResult> deviceLogin({
    required String email,
    required String password,
    required DeviceInfo device,
    required String challenge,
    required String signature,
  }) => _api.post(
    '/${Endpoints.deviceLoginUrl}',
    (value) =>
        DeviceSignInResult.fromJson(Map<String, dynamic>.from(value as Map)),
    body: {
      'email': email,
      'password': password,
      'device': device.toJson(),
      'challenge': challenge,
      'signature': signature,
    },
    auth: false,
  );

  Future<DeviceSignInResult> deviceGoogle({
    required String credential,
    required DeviceInfo device,
    required String challenge,
    required String signature,
  }) => _api.post(
    '/${Endpoints.deviceGoogleUrl}',
    (value) =>
        DeviceSignInResult.fromJson(Map<String, dynamic>.from(value as Map)),
    body: {
      'credential': credential,
      'device': device.toJson(),
      'challenge': challenge,
      'signature': signature,
    },
    auth: false,
  );

  Future<DeviceSignInResult> deviceApple({
    required AppleSignInPayload apple,
    required DeviceInfo device,
    required String challenge,
    required String signature,
  }) => _api.post(
    '/${Endpoints.deviceAppleUrl}',
    (value) =>
        DeviceSignInResult.fromJson(Map<String, dynamic>.from(value as Map)),
    body: {
      ...apple.toJson(),
      'device': device.toJson(),
      'challenge': challenge,
      'signature': signature,
    },
    auth: false,
  );

  Future<DeviceSignInResult> approveDevice({
    required String deviceId,
    required String code,
    required String challenge,
    required String signature,
  }) => _api.post(
    '/${Endpoints.deviceApproveUrl}',
    (value) =>
        DeviceSignInResult.fromJson(Map<String, dynamic>.from(value as Map)),
    body: {
      'deviceId': deviceId,
      'code': code,
      'challenge': challenge,
      'signature': signature,
    },
    auth: false,
  );

  Future<void> reportUnrecognisedDevice(String token) => _api.post<void>(
    '/${Endpoints.deviceNotMeUrl}',
    (_) {},
    body: {'token': token},
    auth: false,
  );

  Future<void> saveDeviceBoundSession(DeviceSignInResult result) async {
    final accessToken = result.accessToken?.trim() ?? '';
    final refreshToken = result.refreshToken?.trim() ?? '';
    if (!result.isSignedIn || accessToken.isEmpty || refreshToken.isEmpty) {
      throw const FormatException(
        'The device sign-in response did not contain both tokens.',
      );
    }
    await _api.store.saveDeviceBoundSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      deviceId: result.deviceId,
    );
  }

  Future<AuthTokens> registerForSession({
    required String name,
    required String email,
    required String password,
  }) => _api.post(
    '/auth/register',
    (value) => AuthTokens.fromJson(Map<String, dynamic>.from(value as Map)),
    body: {'name': name, 'email': email, 'password': password},
    auth: false,
  );

  Future<void> saveTokens(AuthTokens tokens) => _api.store.save(
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    deviceBound: false,
  );

  Future<void> clearSession() => _api.store.clear();

  Future<void> requestPasswordReset(String email) => _api.post<void>(
    '/auth/password/forgot',
    (_) {},
    body: {'email': email},
    auth: false,
  );

  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  }) => _api.post(
    '/auth/password/verify',
    (value) => (value as Map)['resetToken'].toString(),
    body: {'email': email, 'code': code},
    auth: false,
  );

  Future<void> completePasswordReset({
    required String resetToken,
    required String password,
  }) => _api.post<void>(
    '/auth/password/reset',
    (_) {},
    body: {'resetToken': resetToken, 'password': password},
    auth: false,
  );

  Future<void> logoutSession() async {
    final refreshToken = await _api.store.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;
    await _api
        .post<void>(
          Endpoints.logoutUrl,
          (_) {},
          body: {'refreshToken': refreshToken},
        )
        .catchError((_) {});
  }

  Map<String, String> get _authorizedHeaders => {
    ..._headers,
    'Authorization': 'Bearer ${globals.token}',
  };

  Future<http.Response> _post(
    String endpoint,
    Map<String, dynamic> body, {
    required String logLabel,
    bool authorized = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Endpoints.baseUrl}$endpoint'),
        body: jsonEncode(body),
        headers: authorized ? _authorizedHeaders : _headers,
      );
      printData(logLabel, response.body);
      return response;
    } catch (error) {
      return Future.error(handleHttpError(error));
    }
  }
}
