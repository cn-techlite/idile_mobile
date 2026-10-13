import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/home/data/model/dashboard/dashboard_attention.dart';

class DashboardAttentionRemoteService {
  const DashboardAttentionRemoteService(this._api);

  final ApiClient _api;

  Future<DashboardAttention> attention() => _api.get(
    Endpoints.dashboardAttentionUrl,
    (value) =>
        DashboardAttention.fromJson(Map<String, dynamic>.from(value as Map)),
  );
}
