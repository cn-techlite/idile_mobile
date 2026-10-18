import 'package:idile_mobile_app/features/home/domain/entities/dashboard/dashboard_attention.dart';
import 'package:idile_mobile_app/features/home/domain/repositories/dashboard/dashboard_attention_repository.dart';

final class DashboardAttentionUseCases {
  const DashboardAttentionUseCases(this._repository);

  final DashboardAttentionRepository _repository;

  Future<DashboardAttention> attention() => _repository.attention();
}
