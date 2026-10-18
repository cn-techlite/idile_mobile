import 'package:idile_mobile_app/features/home/domain/entities/hearth/hearth_models.dart';
import 'package:idile_mobile_app/features/home/data/service/hearth/hearth_service.dart';
import 'package:idile_mobile_app/features/home/domain/repositories/hearth/hearth_repository.dart';

class HearthRepositoryImpl implements HearthRepository {
  const HearthRepositoryImpl(this._service);
  final HearthService _service;

  @override
  Future<List<WorkspaceAsset>> assets(String? id) => _service.assets(id);
  @override
  Future<void> createAsset(
    Map<String, String> fields, {
    List<int>? bytes,
    String? fileName,
  }) async {
    await _service.createAsset(fields, bytes: bytes, fileName: fileName);
  }

  @override
  Future<void> removeAsset(String id) => _service.removeAsset(id);
  @override
  Future<AdminStats> adminStats() => _service.adminStats();
  @override
  Future<List<AdminUser>> adminUsers() => _service.adminUsers();
  @override
  Future<List<AdminEmail>> adminEmails() => _service.adminEmails();
  @override
  Future<AdminHealth> adminHealth() => _service.adminHealth();
  @override
  Future<void> setUserDisabled(String id, bool disabled) =>
      _service.setUserDisabled(id, disabled);
  @override
  Future<void> retryEmail(String id) => _service.retryEmail(id);
  @override
  Future<void> runReminderSweep() => _service.runReminderSweep();
  @override
  Future<List<Json>> adminAudit() => _service.adminAudit();
  @override
  Future<Json> adminTrends() => _service.adminTrends();
}
