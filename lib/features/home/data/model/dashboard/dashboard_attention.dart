import 'package:idile_mobile_app/features/bills/data/model/bills/bill.dart';
import 'package:idile_mobile_app/features/more/data/model/assets/asset_item.dart';
import 'package:idile_mobile_app/features/more/data/model/documents/document_item.dart';
import 'package:idile_mobile_app/features/more/data/model/maintenance/maintenance_task.dart';
import 'package:idile_mobile_app/features/subs/data/model/subscriptions/subscription.dart';

class DashboardAttention {
  const DashboardAttention({
    this.bills = const [],
    this.subscriptions = const [],
    this.maintenance = const [],
    this.assets = const [],
    this.documents = const [],
  });

  factory DashboardAttention.fromJson(Map<String, dynamic> json) =>
      DashboardAttention(
        bills: _decodeList(json['bills'], Bill.fromJson),
        subscriptions: _decodeList(
          json['subscriptions'],
          SubscriptionItem.fromJson,
        ),
        maintenance: _decodeList(json['maintenance'], MaintenanceTask.fromJson),
        assets: _decodeList(json['assets'], AssetItem.fromJson),
        documents: _decodeList(json['documents'], DocumentItem.fromJson),
      );

  final List<Bill> bills;
  final List<SubscriptionItem> subscriptions;
  final List<MaintenanceTask> maintenance;
  final List<AssetItem> assets;
  final List<DocumentItem> documents;

  int get total =>
      bills.length +
      subscriptions.length +
      maintenance.length +
      assets.length +
      documents.length;
}

List<T> _decodeList<T>(
  Object? value,
  T Function(Map<String, dynamic>) decode,
) => (value as List? ?? const [])
    .map((item) => decode(Map<String, dynamic>.from(item as Map)))
    .toList(growable: false);
