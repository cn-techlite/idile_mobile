/// Shared models used by Home catalog and administration features.
typedef Json = Map<String, dynamic>;

Json _json(dynamic value) => Map<String, dynamic>.from(value as Map);
String _text(dynamic value) => value?.toString() ?? '';
List<T> decodeList<T>(dynamic value, T Function(Json) decode) =>
    (value as List? ?? const []).map((item) => decode(_json(item))).toList();

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});
  factory AuthTokens.fromJson(Json json) => AuthTokens(
    accessToken: _text(json['accessToken']),
    refreshToken: _text(json['refreshToken']),
  );
  final String accessToken;
  final String refreshToken;
}

class WorkspaceAsset {
  const WorkspaceAsset({
    required this.id,
    required this.title,
    required this.spaceId,
    required this.type,
    required this.detail,
    required this.renewal,
    required this.status,
    this.secureUrl,
  });
  factory WorkspaceAsset.fromJson(Json json) => WorkspaceAsset(
    id: _text(json['_id'] ?? json['id']),
    title: _text(json['title']),
    spaceId: _text(json['spaceId']),
    type: _text(json['type']),
    detail: _text(json['detail']),
    renewal: _text(json['renewal']),
    status: _text(json['status']),
    secureUrl: json['secureUrl']?.toString(),
  );
  final String id;
  final String title;
  final String spaceId;
  final String type;
  final String detail;
  final String renewal;
  final String status;
  final String? secureUrl;
}

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.title,
    required this.spaceId,
    required this.type,
    required this.related,
    required this.status,
    this.expiry,
    this.householdItemId,
    this.assetId,
    this.secureUrl,
  });
  factory DocumentItem.fromJson(Json json) => DocumentItem(
    id: _text(json['_id'] ?? json['id']),
    title: _text(json['title']),
    spaceId: _text(json['spaceId']),
    type: _text(json['type']),
    related: _text(json['related']),
    status: _text(json['status']),
    expiry: json['expiry']?.toString(),
    householdItemId: json['householdItemId']?.toString(),
    assetId: json['assetId']?.toString(),
    secureUrl: json['secureUrl']?.toString(),
  );
  final String id;
  final String title;
  final String spaceId;
  final String type;
  final String related;
  final String status;
  final String? expiry;
  final String? householdItemId;
  final String? assetId;
  final String? secureUrl;
}

class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsers,
    required this.remindersToday,
    required this.items,
  });
  factory AdminStats.fromJson(Json json) {
    final users = json['users'] is Map
        ? _json(json['users'])
        : <String, dynamic>{};
    return AdminStats(
      totalUsers: (users['total'] as num?)?.toInt() ?? 0,
      activeUsers: (users['active'] as num?)?.toInt() ?? 0,
      newUsers: (users['new30'] as num?)?.toInt() ?? 0,
      remindersToday: (json['remindersToday'] as num?)?.toInt() ?? 0,
      items: (json['items'] is Map ? _json(json['items']) : const {}).map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
    );
  }
  final int totalUsers;
  final int activeUsers;
  final int newUsers;
  final int remindersToday;
  final Map<String, int> items;
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.disabledAt,
  });
  factory AdminUser.fromJson(Json json) => AdminUser(
    id: _text(json['id'] ?? json['_id']),
    name: _text(json['name']),
    email: _text(json['email']),
    role: _text(json['role']),
    disabledAt: json['disabledAt']?.toString(),
  );
  final String id, name, email, role;
  final String? disabledAt;
}

class AdminEmail {
  const AdminEmail({
    required this.id,
    required this.to,
    required this.subject,
    required this.status,
    required this.attempts,
  });
  factory AdminEmail.fromJson(Json json) => AdminEmail(
    id: _text(json['id'] ?? json['_id']),
    to: _text(json['to']),
    subject: _text(json['subject']),
    status: _text(json['status']),
    attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  );
  final String id, to, subject, status;
  final int attempts;
}

class AdminHealth {
  const AdminHealth({
    required this.database,
    required this.pendingEmails,
    required this.failedEmails,
    required this.webhookConfigured,
  });
  factory AdminHealth.fromJson(Json json) {
    final queue = json['emailQueue'] is Map
        ? _json(json['emailQueue'])
        : <String, dynamic>{};
    return AdminHealth(
      database: _text(json['database']),
      pendingEmails: (queue['pending'] as num?)?.toInt() ?? 0,
      failedEmails: (queue['failedLast24h'] as num?)?.toInt() ?? 0,
      webhookConfigured: json['resendWebhookConfigured'] == true,
    );
  }
  final String database;
  final int pendingEmails, failedEmails;
  final bool webhookConfigured;
}
