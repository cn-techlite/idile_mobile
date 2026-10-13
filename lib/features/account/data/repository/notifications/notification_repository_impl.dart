import 'package:idile_mobile_app/features/account/data/dto/notifications/get_notifications_request.dart';
import 'package:idile_mobile_app/features/account/data/model/notifications/in_app_notification.dart';
import 'package:idile_mobile_app/features/account/data/service/notifications/notification_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/notifications/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remoteService);

  final NotificationRemoteService _remoteService;

  @override
  Future<NotificationPage> notifications(GetNotificationsRequest request) =>
      _remoteService.notifications(request);

  @override
  Future<InAppNotification> markRead(String notificationId) =>
      _remoteService.markRead(notificationId);

  @override
  Future<void> markAllRead() => _remoteService.markAllRead();
}
