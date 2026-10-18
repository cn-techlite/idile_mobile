import 'package:idile_mobile_app/features/account/domain/parameters/categories/create_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/update_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/categories/category.dart';
import 'package:idile_mobile_app/features/account/data/service/categories/category_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/categories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remoteService);

  final CategoryRemoteService _remoteService;

  @override
  Future<List<Category>> categories() => _remoteService.categories();

  @override
  Future<Category> createCategory(CreateCategoryRequest request) =>
      _remoteService.createCategory(request);

  @override
  Future<Category> updateCategory(
    String categoryId,
    UpdateCategoryRequest request,
  ) => _remoteService.updateCategory(categoryId, request);

  @override
  Future<bool> deleteCategory(String categoryId) =>
      _remoteService.deleteCategory(categoryId);
}
