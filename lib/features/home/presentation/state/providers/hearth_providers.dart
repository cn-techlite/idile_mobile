import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/model/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/home/data/model/hearth/hearth_models.dart';
import 'package:idile_mobile_app/features/home/data/repository/hearth/hearth_repository_impl.dart';
import 'package:idile_mobile_app/features/home/data/service/hearth/hearth_service.dart';
import 'package:idile_mobile_app/features/home/domain/controller/hearth/hearth_controllers.dart';
import 'package:idile_mobile_app/features/home/domain/usecases/hearth/hearth_repository.dart';

final hearthServiceProvider = Provider<HearthService>(
  (ref) => HearthService(ref.read(apiClientProvider)),
);
final hearthRepositoryProvider = Provider<HearthRepository>(
  (ref) => HearthRepositoryImpl(ref.read(hearthServiceProvider)),
);
final catalogControllerProvider =
    AsyncNotifierProvider<CatalogController, Catalog>(CatalogController.new);
final workspaceControllerProvider =
    AsyncNotifierProvider<WorkspaceController, List<WorkspaceAsset>>(
      WorkspaceController.new,
    );
final adminStatsProvider = FutureProvider<AdminStats>(
  (ref) => ref.read(hearthRepositoryProvider).adminStats(),
);
final adminUsersProvider = FutureProvider<List<AdminUser>>(
  (ref) => ref.read(hearthRepositoryProvider).adminUsers(),
);
final adminEmailsProvider = FutureProvider<List<AdminEmail>>(
  (ref) => ref.read(hearthRepositoryProvider).adminEmails(),
);
final adminHealthProvider = FutureProvider<AdminHealth>(
  (ref) => ref.read(hearthRepositoryProvider).adminHealth(),
);
final adminAuditProvider = FutureProvider<List<Json>>(
  (ref) => ref.read(hearthRepositoryProvider).adminAudit(),
);
final adminTrendsProvider = FutureProvider<Json>(
  (ref) => ref.read(hearthRepositoryProvider).adminTrends(),
);
