import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/more/data/repository/maintenance/maintenance_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/service/maintenance/maintenance_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/controller/maintenance/maintenance_controller.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/maintenance/maintenance_repository.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/maintenance_state.dart';

final maintenanceRemoteServiceProvider = Provider<MaintenanceRemoteService>(
  (ref) => MaintenanceRemoteService(ref.read(apiClientProvider)),
);

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>(
  (ref) =>
      MaintenanceRepositoryImpl(ref.read(maintenanceRemoteServiceProvider)),
);

final maintenanceControllerProvider =
    AsyncNotifierProvider<MaintenanceController, MaintenanceState>(
      MaintenanceController.new,
    );
