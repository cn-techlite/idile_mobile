import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notifications/get_notifications_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notifications/in_app_notification.dart';

class NotificationRemoteService {
  const NotificationRemoteService(this._api);

  final ApiClient _api;

  Future<NotificationPage> notifications(GetNotificationsRequest request) {
    final uri = Uri(
      path: Endpoints.notificationsUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.getEnvelope(
      uri.toString(),
      (value) => NotificationPage.fromEnvelope(
        Map<String, dynamic>.from(value as Map),
      ),
    );
  }

  Future<InAppNotification> markRead(String notificationId) {
    final id = notificationId.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        notificationId,
        'notificationId',
        'Notification id cannot be empty.',
      );
    }
    return _api.patch(
      Endpoints.notificationReadUrl(id),
      (value) =>
          InAppNotification.fromJson(Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<void> markAllRead() async {
    await _api.patch<Map<String, dynamic>>(
      Endpoints.notificationsReadAllUrl,
      (value) => Map<String, dynamic>.from(value as Map),
    );
  }
}
