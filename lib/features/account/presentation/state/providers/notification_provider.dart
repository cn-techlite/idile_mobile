import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/controller/notifications/notification_controller.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/notification_state.dart';

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );
