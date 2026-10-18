class RegisteredDevice {
  const RegisteredDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.lastUsedAt,
    this.revokedAt,
  });

  factory RegisteredDevice.fromJson(Map<String, dynamic> json) =>
      RegisteredDevice(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: (json['name'] ?? 'Unnamed device').toString(),
        platform: (json['platform'] ?? 'unknown').toString(),
        status: (json['status'] ?? 'pending').toString(),
        createdAt: _date(json['createdAt']),
        approvedAt: _date(json['approvedAt']),
        lastUsedAt: _date(json['lastUsedAt']),
        revokedAt: _date(json['revokedAt']),
      );

  final String id;
  final String name;
  final String platform;
  final String status;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;

  bool get isRevoked => status.toLowerCase() == 'revoked';
  bool get canRevoke => id.isNotEmpty && !isRevoked;

  RegisteredDevice copyWith({
    String? id,
    String? name,
    String? platform,
    String? status,
    Object? createdAt = _unset,
    Object? approvedAt = _unset,
    Object? lastUsedAt = _unset,
    Object? revokedAt = _unset,
  }) => RegisteredDevice(
    id: id ?? this.id,
    name: name ?? this.name,
    platform: platform ?? this.platform,
    status: status ?? this.status,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    approvedAt: identical(approvedAt, _unset)
        ? this.approvedAt
        : approvedAt as DateTime?,
    lastUsedAt: identical(lastUsedAt, _unset)
        ? this.lastUsedAt
        : lastUsedAt as DateTime?,
    revokedAt: identical(revokedAt, _unset)
        ? this.revokedAt
        : revokedAt as DateTime?,
  );
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

const _unset = Object();
