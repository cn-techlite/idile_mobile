import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/repository/categories/category_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/service/categories/category_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/controller/categories/category_controller.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/categories/category_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/category_state.dart';

final categoryRemoteServiceProvider = Provider<CategoryRemoteService>(
  (ref) => CategoryRemoteService(ref.read(apiClientProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.read(categoryRemoteServiceProvider)),
);

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, CategoryState>(
      CategoryController.new,
    );
