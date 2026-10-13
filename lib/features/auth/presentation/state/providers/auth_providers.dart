import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/model/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/account_provider.dart';
import 'package:idile_mobile_app/features/auth/data/repository/idile_auth_repository_impl.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/push_token_registration_service.dart';
import 'package:idile_mobile_app/features/auth/domain/controller/session_controller.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/idile_auth_repository.dart';

final sessionAuthServiceProvider = Provider<AuthRemoteService>(
  (ref) => AuthRemoteService(apiClient: ref.read(apiClientProvider)),
);
final sessionLocalStorageProvider = Provider<AuthLocalStorageService>(
  (ref) => AuthLocalStorageService(),
);
final sessionStateServiceProvider = Provider<AuthSessionService>(
  (ref) => AuthSessionService(),
);
final sessionSocialAuthServiceProvider = Provider<SocialAuthService>(
  (ref) => SocialAuthService(),
);
final sessionPushTokenRegistrationProvider =
    Provider<PushTokenRegistrationService>(
      (ref) => PushTokenRegistrationService(
        apiClient: ref.read(apiClientProvider),
        localStorage: ref.read(sessionLocalStorageProvider),
      ),
    );
final authRepositoryProvider = Provider<IdileAuthRepository>(
  (ref) => IdileAuthRepositoryImpl(
    ref.read(sessionAuthServiceProvider),
    ref.read(accountRepositoryProvider),
    ref.read(sessionLocalStorageProvider),
    ref.read(sessionStateServiceProvider),
    ref.read(sessionSocialAuthServiceProvider),
    ref.read(sessionPushTokenRegistrationProvider),
  ),
);
final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, UserProfile?>(
      SessionController.new,
    );
