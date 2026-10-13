class CreateSpaceRequest {
  const CreateSpaceRequest({required this.name, required this.icon});

  final String name;
  final String icon;

  Map<String, dynamic> toJson() {
    final normalizedName = name.trim();
    final normalizedIcon = icon.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Space name cannot be empty.');
    }
    if (normalizedIcon.isEmpty) {
      throw ArgumentError.value(icon, 'icon', 'Space icon cannot be empty.');
    }
    return {'name': normalizedName, 'icon': normalizedIcon};
  }
}
