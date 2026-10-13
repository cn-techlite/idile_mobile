import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/data/dto/profile/update_account_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/profile/upload_avatar_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/reminders/update_reminder_settings_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/notification_settings/update_notification_settings_request.dart';
import 'package:idile_mobile_app/features/account/data/model/reminders/reminder_settings.dart';
import 'package:idile_mobile_app/features/account/data/service/account/account_remote_service.dart';

void main() {
  test('loads and maps the authenticated Idile profile', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), 'https://api.idile.com.ng/v1/users/me');
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['user-agent'], 'IdileMobileApp/1.0.0 (Flutter)');

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'id': 'user-id',
            'email': 'ada@example.com',
            'name': 'Ada Okafor',
            'role': 'user',
            'hasPassword': true,
            'avatarUrl': 'https://res.cloudinary.com/demo/avatar.jpg',
            'defaultSpaceId': 'default-space',
            'householdSpaceId': 'household-space',
            'workspaceSpaceId': 'workspace-space',
            'defaultCurrencyId': 'currency-id',
          },
        }),
        200,
      );
    });
    final apiClient = ApiClient(
      client: client,
      store: SessionStore(storage: const FlutterSecureStorage()),
    );
    final service = AccountRemoteService(apiClient);

    final profile = await service.currentUser();

    expect(profile.id, 'user-id');
    expect(profile.email, 'ada@example.com');
    expect(profile.name, 'Ada Okafor');
    expect(profile.role, 'user');
    expect(profile.hasPassword, isTrue);
    expect(profile.avatarUrl, 'https://res.cloudinary.com/demo/avatar.jpg');
    expect(profile.defaultSpaceId, 'default-space');
    expect(profile.householdSpaceId, 'household-space');
    expect(profile.workspaceSpaceId, 'workspace-space');
    expect(profile.defaultCurrencyId, 'currency-id');
  });

  test('partially updates the authenticated profile with PATCH', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.toString(), 'https://api.idile.com.ng/v1/users/me');
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(request.headers['content-type'], 'application/json');
      expect(jsonDecode(request.body), {
        'name': 'Ada Okafor',
        'defaultCurrencyId': 'currency-id',
      });

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'id': 'user-id',
            'email': 'ada@example.com',
            'name': 'Ada Okafor',
            'role': 'user',
            'hasPassword': true,
            'defaultSpaceId': 'default-space',
            'householdSpaceId': 'household-space',
            'workspaceSpaceId': 'workspace-space',
            'defaultCurrencyId': 'currency-id',
          },
        }),
        200,
      );
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final profile = await service.updateProfile(
      const UpdateAccountRequest(
        name: '  Ada Okafor  ',
        defaultCurrencyId: 'currency-id',
      ),
    );

    expect(profile.name, 'Ada Okafor');
    expect(profile.defaultCurrencyId, 'currency-id');
  });

  test('uploads a validated avatar with multipart PUT', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/users/me/avatar',
      );
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(
        request.headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(request.body, contains('name="file"'));
      expect(request.body, contains('filename="avatar.PNG"'));
      expect(request.body.toLowerCase(), contains('content-type: image/png'));

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'id': 'user-id',
            'email': 'ada@example.com',
            'name': 'Ada Okafor',
            'role': 'user',
            'avatarUrl': 'https://res.cloudinary.com/demo/new-avatar.png',
          },
        }),
        200,
      );
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final profile = await service.uploadAvatar(
      const UploadAvatarRequest(
        fileBytes: [80, 78, 71],
        fileName: 'avatar.PNG',
      ),
    );

    expect(profile.avatarUrl, 'https://res.cloudinary.com/demo/new-avatar.png');
  });

  test('validates avatar file type and size', () {
    const valid = UploadAvatarRequest(fileBytes: [1], fileName: 'profile.webp');
    valid.validate();
    expect(valid.contentType, 'image/webp');

    expect(
      () => const UploadAvatarRequest(
        fileBytes: [1],
        fileName: 'profile.pdf',
      ).validate(),
      throwsArgumentError,
    );
    expect(
      () => UploadAvatarRequest(
        fileBytes: List<int>.filled(
          UploadAvatarRequest.maxFileSizeBytes + 1,
          0,
        ),
        fileName: 'profile.jpg',
      ).validate(),
      throwsArgumentError,
    );
  });

  test('loads all authenticated reminder settings', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/users/me/reminder-settings',
      );
      expect(request.headers['authorization'], 'Bearer access-token');

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'bills': {
              'enabled': true,
              'leadDays': [7, 1, 0],
            },
            'subscriptions': {
              'enabled': false,
              'leadDays': [7, 1],
            },
            'maintenance': {
              'enabled': true,
              'leadDays': [1],
            },
            'expiries': {
              'enabled': true,
              'leadDays': [30, 7, 0],
            },
          },
        }),
        200,
      );
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final settings = await service.reminderSettings();

    expect(settings.bills.enabled, isTrue);
    expect(settings.bills.leadDays, [7, 1, 0]);
    expect(settings.subscriptions.enabled, isFalse);
    expect(settings.maintenance.leadDays, [1]);
    expect(settings.expiries.leadDays, [30, 7, 0]);
    expect(settings.entries.keys, [
      ReminderKind.bills,
      ReminderKind.subscriptions,
      ReminderKind.maintenance,
      ReminderKind.expiries,
    ]);
  });

  test('partially updates reminder settings with PATCH', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/users/me/reminder-settings',
      );
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(jsonDecode(request.body), {
        'bills': {
          'enabled': false,
          'leadDays': [7, 1, 0],
        },
      });

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'bills': {
              'enabled': false,
              'leadDays': [7, 1, 0],
            },
            'subscriptions': {
              'enabled': true,
              'leadDays': [7, 1, 0],
            },
            'maintenance': {
              'enabled': true,
              'leadDays': [7, 1, 0],
            },
            'expiries': {
              'enabled': true,
              'leadDays': [7, 1, 0],
            },
          },
        }),
        200,
      );
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final settings = await service.updateReminderSettings(
      UpdateReminderSettingsRequest.forKind(
        ReminderKind.bills,
        const ReminderPreference(enabled: false, leadDays: [7, 1, 0]),
      ),
    );

    expect(settings.bills.enabled, isFalse);
    expect(settings.subscriptions.enabled, isTrue);
  });

  test('loads notification channels and quiet hours', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/users/me/notification-settings',
      );
      expect(request.headers['authorization'], 'Bearer access-token');
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'channels': {'inApp': true, 'email': false},
            'quietHours': {'enabled': true, 'from': '22:00', 'to': '07:00'},
          },
        }),
        200,
      );
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final settings = await service.notificationSettings();

    expect(settings.channels.inApp, isTrue);
    expect(settings.channels.email, isFalse);
    expect(settings.quietHours.enabled, isTrue);
    expect(settings.quietHours.from, '22:00');
    expect(settings.quietHours.to, '07:00');
  });

  test('partially updates notification settings with PATCH', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/users/me/notification-settings',
      );
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(jsonDecode(request.body), {
        'channelEmail': false,
        'quietHoursEnabled': true,
        'quietHoursFrom': '22:00',
        'quietHoursTo': '07:00',
      });
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'channels': {'inApp': true, 'email': false},
            'quietHours': {'enabled': true, 'from': '22:00', 'to': '07:00'},
          },
        }),
        200,
      );
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final settings = await service.updateNotificationSettings(
      const UpdateNotificationSettingsRequest(
        channelEmail: false,
        quietHoursEnabled: true,
        quietHoursFrom: '22:00',
        quietHoursTo: '07:00',
      ),
    );

    expect(settings.channels.email, isFalse);
    expect(settings.quietHours.enabled, isTrue);
  });
}
