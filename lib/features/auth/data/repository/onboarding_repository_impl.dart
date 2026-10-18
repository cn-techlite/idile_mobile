import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/domain/repositories/onboarding_repository.dart';

final class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._localStorage);

  final AuthLocalStorageService _localStorage;

  @override
  Future<void> completeOnboarding() => _localStorage.writeInt('onBoard', 0);
}
