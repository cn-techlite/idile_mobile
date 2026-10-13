class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.hasPassword = false,
    this.avatarUrl,
    this.birthday,
    this.phone,
    this.providers = const [],
    this.tourCompleted = false,
    this.defaultSpaceId,
    this.householdSpaceId,
    this.workspaceSpaceId,
    this.defaultCurrencyId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    role: (json['role'] ?? 'user').toString(),
    hasPassword: json['hasPassword'] as bool? ?? false,
    avatarUrl: json['avatarUrl']?.toString(),
    birthday: json['birthday']?.toString(),
    phone: json['phone']?.toString(),
    providers: (json['providers'] as List? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false),
    tourCompleted: json['tourCompleted'] as bool? ?? false,
    defaultSpaceId: json['defaultSpaceId']?.toString(),
    householdSpaceId: json['householdSpaceId']?.toString(),
    workspaceSpaceId: json['workspaceSpaceId']?.toString(),
    defaultCurrencyId: json['defaultCurrencyId']?.toString(),
  );

  final String id;
  final String email;
  final String name;
  final String role;
  final bool hasPassword;
  final String? avatarUrl;
  final String? birthday;
  final String? phone;
  final List<String> providers;
  final bool tourCompleted;
  final String? defaultSpaceId;
  final String? householdSpaceId;
  final String? workspaceSpaceId;
  final String? defaultCurrencyId;
}
