import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/repository/notifications/notification_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/service/notifications/notification_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/controller/notifications/notification_controller.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/notifications/notification_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/notification_state.dart';

final notificationRemoteServiceProvider = Provider<NotificationRemoteService>(
  (ref) => NotificationRemoteService(ref.read(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) =>
      NotificationRepositoryImpl(ref.read(notificationRemoteServiceProvider)),
);

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );
