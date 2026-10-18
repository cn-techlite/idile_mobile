import 'package:idile_mobile_app/features/auth/presentation/model/onboarding_model.dart';

List<Map<String, String>> onboardingData = [
  {
    "pre": "Bills, subscriptions, household upkeep and important papers, organized in one place.",
    "text": "Your home's operating system",
    "image": "assets/images/onboarding_home_system.png",
  },
  {
    "pre":
        "See what is due, renewing or expiring before anything becomes urgent.",
    "text": "Know what needs you next",
    "image": "assets/images/onboarding_upcoming.png",
  },
  {
    "pre": "Track what you owe, own and need to look after, wherever you are.",
    "text": "Keep your household moving",
    "image": "assets/images/onboarding_household.png",
  },
];
List<OnboardingModel> formattedOnboardingList = onboardingData
    .map((x) => OnboardingModel.fromJson(x))
    .toList();
