class UpdateCategoryRequest {
  const UpdateCategoryRequest({required this.name});

  final String name;

  Map<String, dynamic> toJson() {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty.');
    }
    return {'name': normalized};
  }
}
