class DevicePublicKey {
  const DevicePublicKey({
    required this.kty,
    required this.crv,
    required this.x,
    required this.y,
  });

  final String kty;
  final String crv;
  final String x;
  final String y;

  factory DevicePublicKey.fromJson(Map<String, dynamic> json) =>
      DevicePublicKey(
        kty: json['kty']?.toString() ?? 'EC',
        crv: json['crv']?.toString() ?? 'P-256',
        x: json['x']?.toString() ?? '',
        y: json['y']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'kty': kty, 'crv': crv, 'x': x, 'y': y};
}

class DeviceInfo {
  const DeviceInfo({
    required this.publicKey,
    required this.name,
    required this.platform,
  });

  final DevicePublicKey publicKey;
  final String name;
  final String platform;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    publicKey: DevicePublicKey.fromJson(
      Map<String, dynamic>.from(json['publicKey'] as Map),
    ),
    name: json['name']?.toString() ?? 'Mobile device',
    platform: json['platform']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'publicKey': publicKey.toJson(),
    'name': name,
    'platform': platform,
  };
}

class DeviceChallenge {
  const DeviceChallenge({required this.challenge, required this.expiresAt});

  final String challenge;
  final DateTime expiresAt;

  factory DeviceChallenge.fromJson(Map<String, dynamic> json) =>
      DeviceChallenge(
        challenge: json['challenge']?.toString() ?? '',
        expiresAt: DateTime.parse(json['expiresAt'].toString()),
      );
}

class DeviceSignInResult {
  const DeviceSignInResult({
    required this.status,
    required this.deviceId,
    this.accessToken,
    this.refreshToken,
  });

  final String status;
  final String deviceId;
  final String? accessToken;
  final String? refreshToken;

  bool get isSignedIn => status == 'signed_in';
  bool get requiresApproval => status == 'approval_required';

  factory DeviceSignInResult.fromJson(Map<String, dynamic> json) =>
      DeviceSignInResult(
        status: json['status']?.toString() ?? '',
        deviceId: json['deviceId']?.toString() ?? '',
        accessToken: json['accessToken']?.toString(),
        refreshToken: json['refreshToken']?.toString(),
      );
}
