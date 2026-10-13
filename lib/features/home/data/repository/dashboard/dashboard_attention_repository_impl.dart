import 'package:idile_mobile_app/features/home/data/model/dashboard/dashboard_attention.dart';
import 'package:idile_mobile_app/features/home/data/service/dashboard/dashboard_attention_remote_service.dart';
import 'package:idile_mobile_app/features/home/domain/usecases/dashboard/dashboard_attention_repository.dart';

class DashboardAttentionRepositoryImpl implements DashboardAttentionRepository {
  const DashboardAttentionRepositoryImpl(this._remoteService);

  final DashboardAttentionRemoteService _remoteService;

  @override
  Future<DashboardAttention> attention() => _remoteService.attention();
}
