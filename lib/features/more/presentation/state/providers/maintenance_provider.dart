import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/more/presentation/controller/maintenance/maintenance_controller.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/maintenance_state.dart';

final maintenanceControllerProvider =
    AsyncNotifierProvider<MaintenanceController, MaintenanceState>(
      MaintenanceController.new,
    );
