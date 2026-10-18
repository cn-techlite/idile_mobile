import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/repository/account/account_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/repository/categories/category_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/repository/currencies/currency_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/repository/devices/device_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/repository/notifications/notification_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/repository/spaces/space_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/service/account/account_remote_service.dart';
import 'package:idile_mobile_app/features/account/data/service/categories/category_remote_service.dart';
import 'package:idile_mobile_app/features/account/data/service/currencies/currency_remote_service.dart';
import 'package:idile_mobile_app/features/account/data/service/devices/device_remote_service.dart';
import 'package:idile_mobile_app/features/account/data/service/notifications/notification_remote_service.dart';
import 'package:idile_mobile_app/features/account/data/service/spaces/space_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/account/account_repository.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/categories/category_repository.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/currencies/currency_repository.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/devices/device_repository.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/notifications/notification_repository.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/spaces/space_repository.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/account/account_use_cases.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/categories/category_use_cases.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/currencies/currency_use_cases.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/devices/device_use_cases.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/notifications/notification_use_cases.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/spaces/space_use_cases.dart';
import 'package:idile_mobile_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:idile_mobile_app/features/auth/data/repository/idile_auth_repository_impl.dart';
import 'package:idile_mobile_app/features/auth/data/repository/onboarding_repository_impl.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/device_binding_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/push_token_registration_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';
import 'package:idile_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:idile_mobile_app/features/auth/domain/repositories/idile_auth_repository.dart';
import 'package:idile_mobile_app/features/auth/domain/repositories/onboarding_repository.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/complete_onboarding_use_case.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/session_use_cases.dart';
import 'package:idile_mobile_app/features/bills/data/repository/bills/bill_repository_impl.dart';
import 'package:idile_mobile_app/features/bills/data/service/bills/bill_remote_service.dart';
import 'package:idile_mobile_app/features/bills/domain/repositories/bills/bill_repository.dart';
import 'package:idile_mobile_app/features/bills/domain/usecases/bills/bill_use_cases.dart';
import 'package:idile_mobile_app/features/home/data/repository/dashboard/dashboard_attention_repository_impl.dart';
import 'package:idile_mobile_app/features/home/data/repository/hearth/hearth_repository_impl.dart';
import 'package:idile_mobile_app/features/home/data/service/dashboard/dashboard_attention_remote_service.dart';
import 'package:idile_mobile_app/features/home/data/service/hearth/hearth_service.dart';
import 'package:idile_mobile_app/features/home/domain/repositories/dashboard/dashboard_attention_repository.dart';
import 'package:idile_mobile_app/features/home/domain/repositories/hearth/hearth_repository.dart';
import 'package:idile_mobile_app/features/home/domain/usecases/dashboard/dashboard_attention_use_cases.dart';
import 'package:idile_mobile_app/features/home/domain/usecases/hearth/hearth_use_cases.dart';
import 'package:idile_mobile_app/features/more/data/repository/assets/asset_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/repository/calendar/calendar_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/repository/documents/document_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/repository/household_items/household_item_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/repository/maintenance/maintenance_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/service/assets/asset_remote_service.dart';
import 'package:idile_mobile_app/features/more/data/service/calendar/calendar_remote_service.dart';
import 'package:idile_mobile_app/features/more/data/service/documents/document_remote_service.dart';
import 'package:idile_mobile_app/features/more/data/service/household_items/household_item_remote_service.dart';
import 'package:idile_mobile_app/features/more/data/service/maintenance/maintenance_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/assets/asset_repository.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/calendar/calendar_repository.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/documents/document_repository.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/household_items/household_item_repository.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/maintenance/maintenance_repository.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/assets/asset_use_cases.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/calendar/calendar_use_cases.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/documents/document_use_cases.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/household_items/household_item_use_cases.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/maintenance/maintenance_use_cases.dart';
import 'package:idile_mobile_app/features/subs/data/repository/subscriptions/subscription_repository_impl.dart';
import 'package:idile_mobile_app/features/subs/data/service/subscriptions/subscription_remote_service.dart';
import 'package:idile_mobile_app/features/subs/domain/repositories/subscriptions/subscription_repository.dart';
import 'package:idile_mobile_app/features/subs/domain/usecases/subscriptions/subscription_use_cases.dart';

final _authRemoteServiceProvider = Provider<AuthRemoteService>(
  (ref) => AuthRemoteService(apiClient: ref.read(apiClientProvider)),
);
final _socialAuthServiceProvider = Provider<SocialAuthService>(
  (ref) => SocialAuthService(),
);
final _deviceBindingServiceProvider = Provider<DeviceBindingService>(
  (ref) => DeviceBindingService(),
);
final _authLocalStorageServiceProvider = Provider<AuthLocalStorageService>(
  (ref) => AuthLocalStorageService(),
);
final _authSessionServiceProvider = Provider<AuthSessionService>(
  (ref) => AuthSessionService(),
);
final _pushTokenRegistrationServiceProvider =
    Provider<PushTokenRegistrationService>(
      (ref) => PushTokenRegistrationService(
        apiClient: ref.read(apiClientProvider),
        localStorage: ref.read(_authLocalStorageServiceProvider),
      ),
    );
final _legacyAuthRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteService: ref.read(_authRemoteServiceProvider),
    socialAuthService: ref.read(_socialAuthServiceProvider),
    localStorageService: ref.read(_authLocalStorageServiceProvider),
    sessionService: ref.read(_authSessionServiceProvider),
    deviceBindingService: ref.read(_deviceBindingServiceProvider),
    pushTokenRegistration: ref.read(_pushTokenRegistrationServiceProvider),
  ),
);
final authUseCasesProvider = Provider<AuthUseCases>(
  (ref) => AuthUseCases(ref.read(_legacyAuthRepositoryProvider)),
);

final _accountRemoteServiceProvider = Provider<AccountRemoteService>(
  (ref) => AccountRemoteService(ref.read(apiClientProvider)),
);
final _accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepositoryImpl(
    ref.read(_accountRemoteServiceProvider),
    ref.read(_authLocalStorageServiceProvider),
  ),
);
final accountUseCasesProvider = Provider<AccountUseCases>(
  (ref) => AccountUseCases(ref.read(_accountRepositoryProvider)),
);
final _idileAuthRepositoryProvider = Provider<IdileAuthRepository>(
  (ref) => IdileAuthRepositoryImpl(
    ref.read(_authRemoteServiceProvider),
    ref.read(_accountRepositoryProvider),
    ref.read(_authLocalStorageServiceProvider),
    ref.read(_authSessionServiceProvider),
    ref.read(_socialAuthServiceProvider),
    ref.read(_pushTokenRegistrationServiceProvider),
  ),
);
final sessionUseCasesProvider = Provider<SessionUseCases>(
  (ref) => SessionUseCases(ref.read(_idileAuthRepositoryProvider)),
);
final _onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(ref.read(_authLocalStorageServiceProvider)),
);
final completeOnboardingUseCaseProvider = Provider<CompleteOnboardingUseCase>(
  (ref) => CompleteOnboardingUseCase(ref.read(_onboardingRepositoryProvider)),
);

final _categoryRemoteServiceProvider = Provider<CategoryRemoteService>(
  (ref) => CategoryRemoteService(ref.read(apiClientProvider)),
);
final _categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.read(_categoryRemoteServiceProvider)),
);
final categoryUseCasesProvider = Provider<CategoryUseCases>(
  (ref) => CategoryUseCases(ref.read(_categoryRepositoryProvider)),
);
final _currencyRemoteServiceProvider = Provider<CurrencyRemoteService>(
  (ref) => CurrencyRemoteService(ref.read(apiClientProvider)),
);
final _currencyRepositoryProvider = Provider<CurrencyRepository>(
  (ref) => CurrencyRepositoryImpl(ref.read(_currencyRemoteServiceProvider)),
);
final currencyUseCasesProvider = Provider<CurrencyUseCases>(
  (ref) => CurrencyUseCases(ref.read(_currencyRepositoryProvider)),
);
final _deviceRemoteServiceProvider = Provider<DeviceRemoteService>(
  (ref) => DeviceRemoteService(ref.read(apiClientProvider)),
);
final _deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepositoryImpl(ref.read(_deviceRemoteServiceProvider)),
);
final deviceUseCasesProvider = Provider<DeviceUseCases>(
  (ref) => DeviceUseCases(ref.read(_deviceRepositoryProvider)),
);
final _notificationRemoteServiceProvider = Provider<NotificationRemoteService>(
  (ref) => NotificationRemoteService(ref.read(apiClientProvider)),
);
final _notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) =>
      NotificationRepositoryImpl(ref.read(_notificationRemoteServiceProvider)),
);
final notificationUseCasesProvider = Provider<NotificationUseCases>(
  (ref) => NotificationUseCases(ref.read(_notificationRepositoryProvider)),
);
final _spaceRemoteServiceProvider = Provider<SpaceRemoteService>(
  (ref) => SpaceRemoteService(ref.read(apiClientProvider)),
);
final _spaceRepositoryProvider = Provider<SpaceRepository>(
  (ref) => SpaceRepositoryImpl(ref.read(_spaceRemoteServiceProvider)),
);
final spaceUseCasesProvider = Provider<SpaceUseCases>(
  (ref) => SpaceUseCases(ref.read(_spaceRepositoryProvider)),
);

final _billRemoteServiceProvider = Provider<BillRemoteService>(
  (ref) => BillRemoteService(ref.read(apiClientProvider)),
);
final _billRepositoryProvider = Provider<BillRepository>(
  (ref) => BillRepositoryImpl(ref.read(_billRemoteServiceProvider)),
);
final billUseCasesProvider = Provider<BillUseCases>(
  (ref) => BillUseCases(ref.read(_billRepositoryProvider)),
);
final _dashboardAttentionRemoteServiceProvider =
    Provider<DashboardAttentionRemoteService>(
      (ref) => DashboardAttentionRemoteService(ref.read(apiClientProvider)),
    );
final _dashboardAttentionRepositoryProvider =
    Provider<DashboardAttentionRepository>(
      (ref) => DashboardAttentionRepositoryImpl(
        ref.read(_dashboardAttentionRemoteServiceProvider),
      ),
    );
final dashboardAttentionUseCasesProvider = Provider<DashboardAttentionUseCases>(
  (ref) => DashboardAttentionUseCases(
    ref.read(_dashboardAttentionRepositoryProvider),
  ),
);
final _hearthServiceProvider = Provider<HearthService>(
  (ref) => HearthService(ref.read(apiClientProvider)),
);
final _hearthRepositoryProvider = Provider<HearthRepository>(
  (ref) => HearthRepositoryImpl(ref.read(_hearthServiceProvider)),
);
final hearthUseCasesProvider = Provider<HearthUseCases>(
  (ref) => HearthUseCases(ref.read(_hearthRepositoryProvider)),
);

final _assetRemoteServiceProvider = Provider<AssetRemoteService>(
  (ref) => AssetRemoteService(ref.read(apiClientProvider)),
);
final _assetRepositoryProvider = Provider<AssetRepository>(
  (ref) => AssetRepositoryImpl(ref.read(_assetRemoteServiceProvider)),
);
final assetUseCasesProvider = Provider<AssetUseCases>(
  (ref) => AssetUseCases(ref.read(_assetRepositoryProvider)),
);
final _calendarRemoteServiceProvider = Provider<CalendarRemoteService>(
  (ref) => CalendarRemoteService(ref.read(apiClientProvider)),
);
final _calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => CalendarRepositoryImpl(ref.read(_calendarRemoteServiceProvider)),
);
final calendarUseCasesProvider = Provider<CalendarUseCases>(
  (ref) => CalendarUseCases(ref.read(_calendarRepositoryProvider)),
);
final _documentRemoteServiceProvider = Provider<DocumentRemoteService>(
  (ref) => DocumentRemoteService(ref.read(apiClientProvider)),
);
final _documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepositoryImpl(ref.read(_documentRemoteServiceProvider)),
);
final documentUseCasesProvider = Provider<DocumentUseCases>(
  (ref) => DocumentUseCases(ref.read(_documentRepositoryProvider)),
);
final _householdItemRemoteServiceProvider =
    Provider<HouseholdItemRemoteService>(
      (ref) => HouseholdItemRemoteService(ref.read(apiClientProvider)),
    );
final _householdItemRepositoryProvider = Provider<HouseholdItemRepository>(
  (ref) => HouseholdItemRepositoryImpl(
    ref.read(_householdItemRemoteServiceProvider),
  ),
);
final householdItemUseCasesProvider = Provider<HouseholdItemUseCases>(
  (ref) => HouseholdItemUseCases(ref.read(_householdItemRepositoryProvider)),
);
final _maintenanceRemoteServiceProvider = Provider<MaintenanceRemoteService>(
  (ref) => MaintenanceRemoteService(ref.read(apiClientProvider)),
);
final _maintenanceRepositoryProvider = Provider<MaintenanceRepository>(
  (ref) =>
      MaintenanceRepositoryImpl(ref.read(_maintenanceRemoteServiceProvider)),
);
final maintenanceUseCasesProvider = Provider<MaintenanceUseCases>(
  (ref) => MaintenanceUseCases(ref.read(_maintenanceRepositoryProvider)),
);
final _subscriptionRemoteServiceProvider = Provider<SubscriptionRemoteService>(
  (ref) => SubscriptionRemoteService(ref.read(apiClientProvider)),
);
final _subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) =>
      SubscriptionRepositoryImpl(ref.read(_subscriptionRemoteServiceProvider)),
);
final subscriptionUseCasesProvider = Provider<SubscriptionUseCases>(
  (ref) => SubscriptionUseCases(ref.read(_subscriptionRepositoryProvider)),
);
