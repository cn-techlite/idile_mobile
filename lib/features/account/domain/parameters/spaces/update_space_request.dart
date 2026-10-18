class UpdateSpaceRequest {
  const UpdateSpaceRequest({this.name, this.icon});

  final String? name;
  final String? icon;

  Map<String, dynamic> toJson() {
    if (name == null && icon == null) {
      throw ArgumentError('At least one space field must be supplied.');
    }
    final normalizedName = name?.trim();
    final normalizedIcon = icon?.trim();
    if (normalizedName != null && normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Space name cannot be empty.');
    }
    if (normalizedIcon != null && normalizedIcon.isEmpty) {
      throw ArgumentError.value(icon, 'icon', 'Space icon cannot be empty.');
    }
    final json = <String, dynamic>{};
    if (normalizedName != null) json['name'] = normalizedName;
    if (normalizedIcon != null) json['icon'] = normalizedIcon;
    return json;
  }
}
