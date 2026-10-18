import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/get_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/maintenance/maintenance_task.dart';

abstract interface class MaintenanceRepository {
  Future<MaintenancePage> maintenance(GetMaintenanceRequest request);
  Future<MaintenanceTask> maintenanceTask(String taskId);
  Future<MaintenanceTask> createMaintenance(CreateMaintenanceRequest request);
  Future<MaintenanceTask> updateMaintenance(
    String taskId,
    UpdateMaintenanceRequest request,
  );
  Future<bool> deleteMaintenance(String taskId);
  Future<MaintenanceTask> markDone(String taskId);
}
