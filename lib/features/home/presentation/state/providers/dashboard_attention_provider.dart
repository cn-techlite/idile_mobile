import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/home/data/repository/dashboard/dashboard_attention_repository_impl.dart';
import 'package:idile_mobile_app/features/home/data/service/dashboard/dashboard_attention_remote_service.dart';
import 'package:idile_mobile_app/features/home/domain/controller/dashboard/dashboard_attention_controller.dart';
import 'package:idile_mobile_app/features/home/domain/usecases/dashboard/dashboard_attention_repository.dart';
import 'package:idile_mobile_app/features/home/presentation/state/state_model/dashboard_attention_state.dart';

final dashboardAttentionRemoteServiceProvider =
    Provider<DashboardAttentionRemoteService>(
      (ref) => DashboardAttentionRemoteService(ref.read(apiClientProvider)),
    );

final dashboardAttentionRepositoryProvider =
    Provider<DashboardAttentionRepository>(
      (ref) => DashboardAttentionRepositoryImpl(
        ref.read(dashboardAttentionRemoteServiceProvider),
      ),
    );

final dashboardControllerProvider =
    AsyncNotifierProvider<
      DashboardAttentionController,
      DashboardAttentionState
    >(DashboardAttentionController.new);
