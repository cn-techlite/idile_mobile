import 'package:idile_mobile_app/features/more/domain/entities/maintenance/maintenance_task.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/get_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/maintenance/maintenance_repository.dart';

final class MaintenanceUseCases {
  const MaintenanceUseCases(this._repository);

  final MaintenanceRepository _repository;

  Future<MaintenancePage> maintenance(GetMaintenanceRequest request) =>
      _repository.maintenance(request);

  Future<MaintenanceTask> maintenanceTask(String taskId) =>
      _repository.maintenanceTask(taskId);

  Future<MaintenanceTask> createMaintenance(CreateMaintenanceRequest request) =>
      _repository.createMaintenance(request);

  Future<MaintenanceTask> updateMaintenance(
    String taskId,
    UpdateMaintenanceRequest request,
  ) => _repository.updateMaintenance(taskId, request);

  Future<bool> deleteMaintenance(String taskId) =>
      _repository.deleteMaintenance(taskId);

  Future<MaintenanceTask> markDone(String taskId) =>
      _repository.markDone(taskId);
}
