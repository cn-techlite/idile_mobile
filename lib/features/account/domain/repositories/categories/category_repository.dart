import 'package:idile_mobile_app/features/account/domain/parameters/categories/create_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/update_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/categories/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> categories();
  Future<Category> createCategory(CreateCategoryRequest request);
  Future<Category> updateCategory(
    String categoryId,
    UpdateCategoryRequest request,
  );
  Future<bool> deleteCategory(String categoryId);
}
