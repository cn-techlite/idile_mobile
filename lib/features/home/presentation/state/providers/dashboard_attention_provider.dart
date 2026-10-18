import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/home/presentation/controller/dashboard/dashboard_attention_controller.dart';
import 'package:idile_mobile_app/features/home/presentation/state/state_model/dashboard_attention_state.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<
      DashboardAttentionController,
      DashboardAttentionState
    >(DashboardAttentionController.new);
