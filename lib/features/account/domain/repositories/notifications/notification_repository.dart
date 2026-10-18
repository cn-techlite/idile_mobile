import 'package:idile_mobile_app/features/account/domain/parameters/notifications/get_notifications_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notifications/in_app_notification.dart';

abstract interface class NotificationRepository {
  Future<NotificationPage> notifications(GetNotificationsRequest request);

  Future<InAppNotification> markRead(String notificationId);

  Future<void> markAllRead();
}
