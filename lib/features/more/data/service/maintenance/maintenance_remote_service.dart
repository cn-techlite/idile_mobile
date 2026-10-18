import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/get_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/maintenance/maintenance_task.dart';

class MaintenanceRemoteService {
  const MaintenanceRemoteService(this._api);

  final ApiClient _api;

  Future<MaintenancePage> maintenance(GetMaintenanceRequest request) {
    final uri = Uri(
      path: Endpoints.maintenanceUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.getEnvelope(
      uri.toString(),
      (value) =>
          MaintenancePage.fromEnvelope(Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<MaintenanceTask> maintenanceTask(String taskId) => _api.get(
    Endpoints.maintenanceTaskUrl(_validId(taskId)),
    (value) =>
        MaintenanceTask.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<MaintenanceTask> createMaintenance(CreateMaintenanceRequest request) =>
      _api.post(
        Endpoints.maintenanceUrl,
        (value) =>
            MaintenanceTask.fromJson(Map<String, dynamic>.from(value as Map)),
        body: request.toJson(),
      );

  Future<MaintenanceTask> updateMaintenance(
    String taskId,
    UpdateMaintenanceRequest request,
  ) => _api.patch(
    Endpoints.maintenanceTaskUrl(_validId(taskId)),
    (value) =>
        MaintenanceTask.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<bool> deleteMaintenance(String taskId) => _api.delete(
    Endpoints.maintenanceTaskUrl(_validId(taskId)),
    (value) => value is Map && value['deleted'] == true,
  );

  Future<MaintenanceTask> markDone(String taskId) => _api.patch(
    Endpoints.markMaintenanceDoneUrl(_validId(taskId)),
    (value) =>
        MaintenanceTask.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        value,
        'taskId',
        'Maintenance task id cannot be empty.',
      );
    }
    return id;
  }
}
