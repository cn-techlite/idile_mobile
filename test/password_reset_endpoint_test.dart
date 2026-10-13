import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/features/auth/data/dto/reset_password_request.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';

void main() {
  test('password reset request uses the v1 forgot-password endpoint', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.forgetPasswordUrl}',
      'https://api.idile.com.ng/v1/auth/password/forgot',
    );
  });

  test('password reset uses the v1 reset endpoint and resetToken field', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.resetPasswordUrl}',
      'https://api.idile.com.ng/v1/auth/password/reset',
    );
    expect(
      const ResetPasswordRequest(
        resetToken: 'single-use-token',
        password: 'new-correct-horse',
      ).toJson(),
      {'resetToken': 'single-use-token', 'password': 'new-correct-horse'},
    );
  });

  test('session refresh uses the v1 refresh endpoint', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.refreshTokenUrl}',
      'https://api.idile.com.ng/v1/auth/refresh',
    );
  });

  test('Google sign-in uses the v1 Google endpoint', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.googleLoginUrl}',
      'https://api.idile.com.ng/v1/auth/google',
    );
  });

  test('Apple sign-in uses the standard and mobile-device endpoints', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.appleLoginUrl}',
      'https://api.idile.com.ng/v1/auth/apple',
    );
    expect(
      '${Endpoints.baseUrl}${Endpoints.deviceAppleUrl}',
      'https://api.idile.com.ng/v1/auth/device/apple',
    );
  });

  test('current user uses the v1 users/me endpoint', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.currentUserUrl}',
      'https://api.idile.com.ng/v1/users/me',
    );
  });

  test('logout uses the v1 logout endpoint', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.logoutUrl}',
      'https://api.idile.com.ng/v1/auth/logout',
    );
  });
}
