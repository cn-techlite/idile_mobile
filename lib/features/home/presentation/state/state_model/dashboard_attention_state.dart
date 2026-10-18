import 'package:idile_mobile_app/features/home/domain/entities/dashboard/dashboard_attention.dart';

class DashboardAttentionState {
  const DashboardAttentionState({
    required this.attention,
    this.isRefreshing = false,
  });

  final DashboardAttention attention;
  final bool isRefreshing;

  DashboardAttentionState copyWith({
    DashboardAttention? attention,
    bool? isRefreshing,
  }) => DashboardAttentionState(
    attention: attention ?? this.attention,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );
}
