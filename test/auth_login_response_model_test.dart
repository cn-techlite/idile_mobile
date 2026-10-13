import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/features/auth/data/model/login_response_model.dart';

void main() {
  test('parses token response and derives identity from access token', () {
    final header = _encode({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _encode({'sub': 'user-123', 'email': 'person@example.com'});

    final model = LoginResponseModel.fromJson({
      'accessToken': '$header.$payload.signature',
      'refreshToken': 'refresh-token',
      'remember': true,
    });

    expect(model.token, '$header.$payload.signature');
    expect(model.refreshToken, 'refresh-token');
    expect(model.userId, 'user-123');
    expect(model.email, 'person@example.com');
    expect(model.remember, isTrue);
    expect(model.emailVerified, isNull);
  });
}

String _encode(Map<String, dynamic> value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
