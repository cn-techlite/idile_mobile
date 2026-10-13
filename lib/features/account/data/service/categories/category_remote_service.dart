import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/account/data/dto/categories/create_category_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/categories/update_category_request.dart';
import 'package:idile_mobile_app/features/account/data/model/categories/category.dart';

class CategoryRemoteService {
  const CategoryRemoteService(this._api);

  final ApiClient _api;

  Future<List<Category>> categories() => _api.get(
    Endpoints.categoriesUrl,
    (value) => (value as List)
        .map(
          (item) => Category.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
  );

  Future<Category> createCategory(CreateCategoryRequest request) => _api.post(
    Endpoints.categoriesUrl,
    (value) => Category.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<Category> updateCategory(
    String categoryId,
    UpdateCategoryRequest request,
  ) => _api.patch(
    Endpoints.categoryUrl(_validId(categoryId)),
    (value) => Category.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<bool> deleteCategory(String categoryId) => _api.delete(
    Endpoints.categoryUrl(_validId(categoryId)),
    (value) => value is Map && value['deleted'] == true,
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        value,
        'categoryId',
        'Category id cannot be empty.',
      );
    }
    return id;
  }
}
