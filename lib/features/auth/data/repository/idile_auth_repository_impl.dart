import 'package:idile_mobile_app/core/network/api_exception.dart';
import 'package:idile_mobile_app/core/services/offline_cache_service.dart';
import 'package:idile_mobile_app/features/account/data/model/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/account/account_repository.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/push_token_registration_service.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/idile_auth_repository.dart';

class IdileAuthRepositoryImpl implements IdileAuthRepository {
  IdileAuthRepositoryImpl(
    this._service,
    this._accountRepository,
    this._localStorageService,
    this._sessionService,
    this._socialAuthService,
    this._pushTokenRegistration,
  );
  final AuthRemoteService _service;
  final AccountRepository _accountRepository;
  final AuthLocalStorageService _localStorageService;
  final AuthSessionService _sessionService;
  final SocialAuthService _socialAuthService;
  final PushTokenRegistrationService _pushTokenRegistration;

  @override
  Future<UserProfile?> restoreSession() async {
    try {
      return await _accountRepository.currentUser();
    } on ApiException catch (error) {
      if (error.isUnauthorized) return null;
      rethrow;
    }
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final tokens = await _service.loginForSession(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    await _service.saveTokens(tokens);
    await _registerPushToken();
    return _accountRepository.currentUser();
  }

  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final tokens = await _service.registerForSession(
      name: name,
      email: email,
      password: password,
    );
    await _service.saveTokens(tokens);
    return _accountRepository.currentUser();
  }

  @override
  Future<void> logout() async {
    try {
      try {
        await _pushTokenRegistration.remove();
      } catch (_) {}
      await _service.logoutSession();
    } finally {
      await _service.clearSession();
      await _socialAuthService.signOutSocials();
      await _localStorageService.clearAuthSession();
      await _sessionService.clear();
      await OfflineCacheService.clear();
    }
  }

  @override
  Future<void> forgotPassword(String email) =>
      _service.requestPasswordReset(email);

  @override
  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) => _service.verifyPasswordResetCode(email: email, code: code);

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  }) => _service.completePasswordReset(
    resetToken: resetToken,
    password: password,
  );

  Future<void> _registerPushToken() async {
    try {
      await _pushTokenRegistration.registerStoredToken(force: true);
    } catch (_) {}
  }
}
