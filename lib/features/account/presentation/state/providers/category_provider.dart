import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/controller/categories/category_controller.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/category_state.dart';

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, CategoryState>(
      CategoryController.new,
    );
