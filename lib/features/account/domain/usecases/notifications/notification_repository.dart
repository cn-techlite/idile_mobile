import 'package:idile_mobile_app/features/account/data/dto/notifications/get_notifications_request.dart';
import 'package:idile_mobile_app/features/account/data/model/notifications/in_app_notification.dart';

abstract interface class NotificationRepository {
  Future<NotificationPage> notifications(GetNotificationsRequest request);

  Future<InAppNotification> markRead(String notificationId);

  Future<void> markAllRead();
}
