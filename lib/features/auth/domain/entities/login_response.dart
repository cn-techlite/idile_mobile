import 'dart:convert';

class LoginResponseModel {
  final String? token;
  final String? refreshToken;
  final String? email;
  final String? userId;
  final String? userType;
  final bool? emailVerified;
  final bool? phoneVerified;
  final String? fullName;
  final String? profileImage;
  final String? idAuthPassword;
  final String? infoCompleted;
  final String? callTokenId;
  final bool? freeSubscription;
  final bool? walletUser;
  final bool? isSubscriptionActive;
  final DateTime? refreshTokenExpiryTime;
  final DateTime? subscriptionExpiresAt;
  final DateTime? subscriptionDate;
  final List<String>? roles;
  final List<String>? permissions;
  final bool? remember;

  LoginResponseModel({
    this.token,
    this.refreshToken,
    this.email,
    this.userId,
    this.userType,
    this.emailVerified,
    this.phoneVerified,
    this.fullName,
    this.profileImage,
    this.idAuthPassword,
    this.infoCompleted,
    this.callTokenId,
    this.freeSubscription,
    this.walletUser,
    this.isSubscriptionActive,
    this.refreshTokenExpiryTime,
    this.subscriptionExpiresAt,
    this.subscriptionDate,
    this.roles,
    this.permissions,
    this.remember,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final token = (json["token"] ?? json["accessToken"] ?? "").toString();
    final claims = _decodeJwtClaims(token);

    return LoginResponseModel(
      token: token,
      refreshToken: json["refreshToken"] ?? "",
      email: json["email"] ?? claims["email"] ?? "",
      userId: json["userId"] ?? json["id"] ?? claims["sub"] ?? "",
      userType: json["userType"] ?? "",
      emailVerified: json["emailVerified"] as bool?,
      phoneVerified: json["phoneVerified"] ?? false,
      fullName: json["fullName"] ?? "",
      profileImage: json["profileImage"] ?? "",
      idAuthPassword: json["idAuthPassword"] ?? "",
      infoCompleted: json["infoCompleted"] ?? "",
      callTokenId: json["callTokenId"] ?? "",
      freeSubscription: json["freeSubscription"] as bool? ?? false,
      walletUser: json["walletUser"] ?? false,
      isSubscriptionActive: json["isSubscriptionActive"] ?? false,
      refreshTokenExpiryTime: json["refreshTokenExpiryTime"] == null
          ? null
          : DateTime.parse(json["refreshTokenExpiryTime"]),
      subscriptionExpiresAt: json["subscriptionExpiresAt"] == null
          ? null
          : DateTime.parse(json["subscriptionExpiresAt"]),
      subscriptionDate: json["subscriptionDate"] == null
          ? null
          : DateTime.parse(json["subscriptionDate"]),
      roles: json["roles"] == null
          ? []
          : List<String>.from(json["roles"]!.map((x) => x)),
      permissions: json["permissions"] == null
          ? []
          : List<String>.from(json["permissions"]!.map((x) => x)),
      remember: json["remember"] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    "token": token,
    "refreshToken": refreshToken,
    "email": email,
    "userId": userId,
    "userType": userType,
    "emailVerified": emailVerified,
    "phoneVerified": phoneVerified,
    "fullName": fullName,
    "profileImage": profileImage,
    "idAuthPassword": idAuthPassword,
    "infoCompleted": infoCompleted,
    "callTokenId": callTokenId,
    "freeSubscription": freeSubscription,
    "walletUser": walletUser,
    "isSubscriptionActive": isSubscriptionActive,
    "refreshTokenExpiryTime": refreshTokenExpiryTime?.toIso8601String(),
    "subscriptionExpiresAt": subscriptionExpiresAt?.toIso8601String(),
    "subscriptionDate": subscriptionDate?.toIso8601String(),
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "permissions": permissions == null
        ? []
        : List<dynamic>.from(permissions!.map((x) => x)),
    "remember": remember,
  };
}

Map<String, dynamic> _decodeJwtClaims(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return const {};

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final decoded = json.decode(payload);
    return decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : const <String, dynamic>{};
  } catch (_) {
    return const {};
  }
}
