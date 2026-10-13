import 'package:idile_mobile_app/features/more/data/dto/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/get_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/model/maintenance/maintenance_task.dart';
import 'package:idile_mobile_app/features/more/data/service/maintenance/maintenance_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/maintenance/maintenance_repository.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  const MaintenanceRepositoryImpl(this._remoteService);

  final MaintenanceRemoteService _remoteService;

  @override
  Future<MaintenancePage> maintenance(GetMaintenanceRequest request) =>
      _remoteService.maintenance(request);

  @override
  Future<MaintenanceTask> maintenanceTask(String taskId) =>
      _remoteService.maintenanceTask(taskId);

  @override
  Future<MaintenanceTask> createMaintenance(CreateMaintenanceRequest request) =>
      _remoteService.createMaintenance(request);

  @override
  Future<MaintenanceTask> updateMaintenance(
    String taskId,
    UpdateMaintenanceRequest request,
  ) => _remoteService.updateMaintenance(taskId, request);

  @override
  Future<bool> deleteMaintenance(String taskId) =>
      _remoteService.deleteMaintenance(taskId);

  @override
  Future<MaintenanceTask> markDone(String taskId) =>
      _remoteService.markDone(taskId);
}
