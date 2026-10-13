class UpdateAccountRequest {
  const UpdateAccountRequest({
    this.name,
    this.defaultSpaceId,
    this.householdSpaceId,
    this.workspaceSpaceId,
    this.defaultCurrencyId,
  });

  final String? name;
  final String? defaultSpaceId;
  final String? householdSpaceId;
  final String? workspaceSpaceId;
  final String? defaultCurrencyId;

  bool get hasChanges =>
      name != null ||
      defaultSpaceId != null ||
      householdSpaceId != null ||
      workspaceSpaceId != null ||
      defaultCurrencyId != null;

  Map<String, dynamic> toJson() {
    if (!hasChanges) {
      throw ArgumentError('At least one profile field must be supplied.');
    }

    final normalizedName = name?.trim();
    if (name != null && normalizedName!.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty.');
    }

    return {
      if (name != null) 'name': normalizedName,
      if (defaultSpaceId != null) 'defaultSpaceId': defaultSpaceId,
      if (householdSpaceId != null) 'householdSpaceId': householdSpaceId,
      if (workspaceSpaceId != null) 'workspaceSpaceId': workspaceSpaceId,
      if (defaultCurrencyId != null) 'defaultCurrencyId': defaultCurrencyId,
    };
  }
}
