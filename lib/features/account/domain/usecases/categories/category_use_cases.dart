import 'package:idile_mobile_app/features/account/domain/entities/categories/category.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/create_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/update_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/categories/category_repository.dart';

final class CategoryUseCases {
  const CategoryUseCases(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> categories() => _repository.categories();

  Future<Category> createCategory(CreateCategoryRequest request) =>
      _repository.createCategory(request);

  Future<Category> updateCategory(
    String categoryId,
    UpdateCategoryRequest request,
  ) => _repository.updateCategory(categoryId, request);

  Future<bool> deleteCategory(String categoryId) =>
      _repository.deleteCategory(categoryId);
}
