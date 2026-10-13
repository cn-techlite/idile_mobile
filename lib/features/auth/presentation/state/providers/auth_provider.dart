import 'package:idile_mobile_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/device_binding_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/push_token_registration_service.dart';
import 'package:idile_mobile_app/features/auth/domain/controller/auth_controller.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/auth_repository.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';

final authRemoteServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteService(apiClient: ref.read(apiClientProvider));
});

final socialAuthServiceProvider = Provider<SocialAuthService>((ref) {
  return SocialAuthService();
});

final deviceBindingServiceProvider = Provider<DeviceBindingService>((ref) {
  return DeviceBindingService();
});

final authLocalStorageServiceProvider = Provider<AuthLocalStorageService>((
  ref,
) {
  return AuthLocalStorageService();
});

final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService();
});

final pushTokenRegistrationServiceProvider =
    Provider<PushTokenRegistrationService>((ref) {
      return PushTokenRegistrationService(
        apiClient: ref.read(apiClientProvider),
        localStorage: ref.read(authLocalStorageServiceProvider),
      );
    });

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteService: ref.read(authRemoteServiceProvider),
    socialAuthService: ref.read(socialAuthServiceProvider),
    localStorageService: ref.read(authLocalStorageServiceProvider),
    sessionService: ref.read(authSessionServiceProvider),
    deviceBindingService: ref.read(deviceBindingServiceProvider),
    pushTokenRegistration: ref.read(pushTokenRegistrationServiceProvider),
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
