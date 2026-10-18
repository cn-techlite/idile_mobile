import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/domain/entities/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/home/domain/entities/hearth/hearth_models.dart';
import 'package:idile_mobile_app/features/home/presentation/controller/hearth/hearth_controllers.dart';

final catalogControllerProvider =
    AsyncNotifierProvider<CatalogController, Catalog>(CatalogController.new);
final workspaceControllerProvider =
    AsyncNotifierProvider<WorkspaceController, List<WorkspaceAsset>>(
      WorkspaceController.new,
    );
final adminStatsProvider = FutureProvider<AdminStats>(
  (ref) => ref.read(hearthUseCasesProvider).adminStats(),
);
final adminUsersProvider = FutureProvider<List<AdminUser>>(
  (ref) => ref.read(hearthUseCasesProvider).adminUsers(),
);
final adminEmailsProvider = FutureProvider<List<AdminEmail>>(
  (ref) => ref.read(hearthUseCasesProvider).adminEmails(),
);
final adminHealthProvider = FutureProvider<AdminHealth>(
  (ref) => ref.read(hearthUseCasesProvider).adminHealth(),
);
final adminAuditProvider = FutureProvider<List<Json>>(
  (ref) => ref.read(hearthUseCasesProvider).adminAudit(),
);
final adminTrendsProvider = FutureProvider<Json>(
  (ref) => ref.read(hearthUseCasesProvider).adminTrends(),
);
