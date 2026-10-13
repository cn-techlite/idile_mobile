import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/features/home/data/model/hearth/hearth_models.dart';

class HearthService {
  const HearthService(this._api);
  final ApiClient _api;

  String _query(String path, Map<String, String?> values) {
    final filtered = Map<String, String>.fromEntries(
      values.entries
          .where((entry) => entry.value != null && entry.value!.isNotEmpty)
          .map((entry) => MapEntry(entry.key, entry.value!)),
    );
    return Uri(
      path: path,
      queryParameters: filtered.isEmpty ? null : filtered,
    ).toString();
  }

  Future<List<WorkspaceAsset>> assets([String? spaceId]) => _api.get(
    _query('/assets', {'spaceId': spaceId}),
    (v) => decodeList(v, WorkspaceAsset.fromJson),
  );
  Future<WorkspaceAsset> createAsset(
    Map<String, String> fields, {
    List<int>? bytes,
    String? fileName,
  }) => _api.multipart(
    '/assets',
    (v) => WorkspaceAsset.fromJson(Map<String, dynamic>.from(v as Map)),
    fields: fields,
    fileBytes: bytes,
    fileName: fileName,
  );
  Future<WorkspaceAsset> updateAsset(String id, Map<String, dynamic> body) =>
      _api.patch(
        '/assets/$id',
        (v) => WorkspaceAsset.fromJson(Map<String, dynamic>.from(v as Map)),
        body: body,
      );
  Future<void> removeAsset(String id) => _api.delete('/assets/$id', (_) {});

  Future<AdminStats> adminStats() => _api.get(
    '/admin/stats',
    (v) => AdminStats.fromJson(Map<String, dynamic>.from(v as Map)),
  );
  Future<List<AdminUser>> adminUsers() =>
      _api.get('/admin/users', (v) => decodeList(v, AdminUser.fromJson));
  Future<List<AdminEmail>> adminEmails() =>
      _api.get('/admin/emails', (v) => decodeList(v, AdminEmail.fromJson));
  Future<AdminHealth> adminHealth() => _api.get(
    '/admin/health',
    (v) => AdminHealth.fromJson(Map<String, dynamic>.from(v as Map)),
  );
  Future<void> setUserDisabled(String id, bool disabled) =>
      _api.patch('/admin/users/$id', (_) {}, body: {'disabled': disabled});
  Future<void> retryEmail(String id) =>
      _api.post('/admin/emails/$id/retry', (_) {});
  Future<void> runReminderSweep() =>
      _api.post('/admin/reminders/sweep', (_) {});
  Future<List<Json>> adminAudit() => _api.get(
    '/admin/audit',
    (v) => (v as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(),
  );
  Future<Json> adminTrends() => _api.get(
    '/admin/trends?days=30',
    (v) => Map<String, dynamic>.from(v as Map),
  );
}
