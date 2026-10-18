import 'package:idile_mobile_app/features/auth/domain/repositories/onboarding_repository.dart';

final class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<void> call() => _repository.completeOnboarding();
}
