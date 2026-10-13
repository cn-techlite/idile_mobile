import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:idile_mobile_app/core/constants/constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint('Unable to initialize background Firebase: $error');
  }
  debugPrint('Background message received: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    this.onTokenAvailable,
  }) : _fcm = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Future<void> Function(String token)? onTokenAvailable;

  String deviceToken = '';

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
    await _requestNotificationPermissions();

    var canFetchToken = true;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      canFetchToken = await _waitForApnsToken();
    }

    if (canFetchToken) {
      await _fetchFcmToken();
    } else {
      debugPrint('APNs registration timed out; awaiting token refresh.');
    }

    await _handleInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.onMessage.listen(showNotification);

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _fcm.onTokenRefresh.listen(_storeAndNotifyToken);
  }

  Future<void> _requestNotificationPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus.name}');

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<bool> _waitForApnsToken() async {
    const maxAttempts = 10;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        if (await _fcm.getAPNSToken() != null) return true;
      } catch (error) {
        debugPrint('Unable to read APNs token: $error');
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> _fetchFcmToken() async {
    try {
      var token = await _fcm.getToken();
      if (token == null) {
        await Future<void>.delayed(const Duration(seconds: 3));
        token = await _fcm.getToken();
      }
      if (token == null) {
        debugPrint('FCM token is unavailable.');
        return;
      }
      await _storeAndNotifyToken(token);
    } catch (error) {
      debugPrint('Unable to fetch the FCM token: $error');
    }
  }

  Future<void> _storeAndNotifyToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    deviceToken = normalizedToken;
    printData('FCM device token', normalizedToken);
    await setToLocalStorage(name: 'deviceToken', data: normalizedToken);

    final callback = onTokenAvailable;
    if (callback == null) return;
    try {
      await callback(normalizedToken);
    } catch (error) {
      debugPrint('Unable to register the FCM token: $error');
    }
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Notification opened: ${message.data}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const appleSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: appleSettings,
        macOS: appleSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
          debugPrint('Local notification opened: $data');
        } catch (error) {
          debugPrint('Invalid notification payload: $error');
        }
      },
    );

    const channel = AndroidNotificationChannel(
      'fcm_default_channel',
      'High Importance Notifications',
      description: 'Important household reminders and updates.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'fcm_default_channel',
      'High Importance Notifications',
      channelDescription: 'Important household reminders and updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      color: Color(0xFFF4C542),
      styleInformation: BigTextStyleInformation(''),
    );
    const appleDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: appleDetails,
        macOS: appleDetails,
      ),
      payload: jsonEncode(message.data),
    );
  }
}
