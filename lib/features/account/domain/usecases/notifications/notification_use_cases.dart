import 'package:idile_mobile_app/features/account/domain/entities/notifications/in_app_notification.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notifications/get_notifications_request.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/notifications/notification_repository.dart';

final class NotificationUseCases {
  const NotificationUseCases(this._repository);

  final NotificationRepository _repository;

  Future<NotificationPage> notifications(GetNotificationsRequest request) =>
      _repository.notifications(request);

  Future<InAppNotification> markRead(String notificationId) =>
      _repository.markRead(notificationId);

  Future<void> markAllRead() => _repository.markAllRead();
}
