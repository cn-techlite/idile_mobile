import 'package:idile_mobile_app/features/more/data/dto/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/get_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/model/maintenance/maintenance_task.dart';

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
