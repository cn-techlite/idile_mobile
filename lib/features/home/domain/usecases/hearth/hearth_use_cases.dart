import 'package:idile_mobile_app/features/home/domain/entities/hearth/hearth_models.dart';
import 'package:idile_mobile_app/features/home/domain/repositories/hearth/hearth_repository.dart';

final class HearthUseCases {
  const HearthUseCases(this._repository);

  final HearthRepository _repository;

  Future<List<WorkspaceAsset>> assets(String? spaceId) =>
      _repository.assets(spaceId);

  Future<void> createAsset(
    Map<String, String> fields, {
    List<int>? bytes,
    String? fileName,
  }) => _repository.createAsset(fields, bytes: bytes, fileName: fileName);

  Future<void> removeAsset(String id) => _repository.removeAsset(id);

  Future<AdminStats> adminStats() => _repository.adminStats();

  Future<List<AdminUser>> adminUsers() => _repository.adminUsers();

  Future<List<AdminEmail>> adminEmails() => _repository.adminEmails();

  Future<AdminHealth> adminHealth() => _repository.adminHealth();

  Future<void> setUserDisabled(String id, bool disabled) =>
      _repository.setUserDisabled(id, disabled);

  Future<void> retryEmail(String id) => _repository.retryEmail(id);

  Future<void> runReminderSweep() => _repository.runReminderSweep();

  Future<List<Json>> adminAudit() => _repository.adminAudit();

  Future<Json> adminTrends() => _repository.adminTrends();
}
