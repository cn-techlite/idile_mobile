import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:idile_mobile_app/app/app.dart';
import 'package:idile_mobile_app/app/router/routers.dart' as router;
import 'package:idile_mobile_app/core/constants/api_constants.dart';
import 'package:idile_mobile_app/core/services/globals.dart';
import 'package:idile_mobile_app/core/services/offline_cache_service.dart';
import 'package:idile_mobile_app/core/services/push_notification_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/push_token_registration_service.dart';
import 'package:path_provider/path_provider.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final firebaseReady = await _initializeFirebaseServices();
  await globals.init();

  final pushTokenRegistration = PushTokenRegistrationService();
  var firstFcmToken = true;
  var fetchedFcmToken = false;
  if (firebaseReady) {
    try {
      final notifications = PushNotificationService(
        onTokenAvailable: (token) async {
          final forceRegistration = firstFcmToken;
          firstFcmToken = false;
          await pushTokenRegistration.register(token, force: forceRegistration);
        },
      );
      await notifications.initialize();
      fetchedFcmToken = notifications.deviceToken.isNotEmpty;
    } catch (error) {
      debugPrint('Push notifications were not initialized: $error');
    }
  }
  if (!fetchedFcmToken) {
    firstFcmToken = false;
    try {
      await pushTokenRegistration.registerStoredToken(force: true);
    } catch (error) {
      debugPrint('Stored push token was not registered: $error');
    }
  }

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await OfflineCacheService.initialize();

  final navigatorKey = GlobalKey<NavigatorState>();
  final initialRoute = await router.initialRoute();

  runApp(
    ProviderScope(
      child: IdileApp(initialRoute: initialRoute, navigatorKey: navigatorKey),
    ),
  );
}

Future<bool> _initializeFirebaseServices() async {
  try {
    await Firebase.initializeApp();
    await GoogleSignIn.instance.initialize(
      clientId: ApiConstants.googleIosClientId.isEmpty
          ? null
          : ApiConstants.googleIosClientId,
      serverClientId: ApiConstants.googleWebClientId.isEmpty
          ? null
          : ApiConstants.googleWebClientId,
    );
    return true;
  } catch (error) {
    // Firebase configuration is platform-specific. Authentication and local
    // data should still open when a platform has not been configured yet.
    debugPrint('Firebase services were not initialized: $error');
    return false;
  }
}
