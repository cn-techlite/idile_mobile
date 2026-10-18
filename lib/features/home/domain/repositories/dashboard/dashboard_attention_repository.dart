import 'package:idile_mobile_app/features/home/domain/entities/dashboard/dashboard_attention.dart';

abstract interface class DashboardAttentionRepository {
  Future<DashboardAttention> attention();
}
