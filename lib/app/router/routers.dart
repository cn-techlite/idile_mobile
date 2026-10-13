import 'package:flutter/material.dart';
import 'package:idile_mobile_app/app/router/route.dart';
import 'package:idile_mobile_app/core/services/globals.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/get_started.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/onboarding_.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/user_register.dart';
import 'package:idile_mobile_app/features/home/presentation/screen/home_screen.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RootRoutes.onboard:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
    case RootRoutes.login:
      return MaterialPageRoute(builder: (context) => const LoginScreens());
    case RootRoutes.createAccount:
      return MaterialPageRoute(builder: (context) => const RegisterScreen());
    case RootRoutes.getStarted:
      return MaterialPageRoute(builder: (context) => const GetStartedScreen());
    case RootRoutes.tab:
      return MaterialPageRoute(
        builder: (context) => const HomeScreenPage(initialIndex: 0),
      );
    default:
      return _errorRoute();
  }
}

Route<dynamic> _errorRoute() => MaterialPageRoute(
  builder: (context) => Scaffold(
    appBar: AppBar(title: const AppText.raw('ERROR'), centerTitle: true),
    body: const Center(child: AppText.raw('Page not found!')),
  ),
);

Future<String> initialRoute() async {
  if (globals.isViewed != 0) return RootRoutes.onboard;
  if (globals.userId.isEmpty) return RootRoutes.login;
  return RootRoutes.tab;
}
