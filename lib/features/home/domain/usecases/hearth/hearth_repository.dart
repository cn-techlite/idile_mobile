import 'package:idile_mobile_app/features/home/data/model/hearth/hearth_models.dart';

abstract interface class HearthRepository {
  Future<List<WorkspaceAsset>> assets(String? spaceId);
  Future<void> createAsset(
    Map<String, String> fields, {
    List<int>? bytes,
    String? fileName,
  });
  Future<void> removeAsset(String id);
  Future<AdminStats> adminStats();
  Future<List<AdminUser>> adminUsers();
  Future<List<AdminEmail>> adminEmails();
  Future<AdminHealth> adminHealth();
  Future<void> setUserDisabled(String id, bool disabled);
  Future<void> retryEmail(String id);
  Future<void> runReminderSweep();
  Future<List<Json>> adminAudit();
  Future<Json> adminTrends();
}
