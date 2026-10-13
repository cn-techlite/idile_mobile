import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:idile_mobile_app/core/constants/api_constants.dart';
import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/errors/error_handling.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/auth/data/model/apple_sign_in_payload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthService {
  SocialAuthService({this._googleSignIn, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  GoogleSignIn? _googleSignIn;
  final http.Client _httpClient;

  GoogleSignIn get googleSignIn => _googleSignIn ??= GoogleSignIn.instance;

  Future<http.Response> signInWithGoogle() async {
    try {
      final idToken = await getGoogleIdToken();
      return await exchangeGoogleCredential(idToken);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialAuthCancelledException();
      }
      return Future.error(handleHttpError(error));
    } catch (error) {
      return Future.error(handleHttpError(error));
    }
  }

  Future<String> getGoogleIdToken() async {
    try {
      final googleUser = await _authenticateGoogleUser();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google sign-in did not return an ID token.');
      }
      validateGoogleIdToken(
        idToken,
        expectedAudience: ApiConstants.googleWebClientId,
      );
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialAuthCancelledException();
      }
      return Future.error(handleHttpError(error));
    }
  }

  Future<http.Response> exchangeGoogleCredential(String credential) async {
    final normalizedCredential = credential.trim();
    if (normalizedCredential.isEmpty) {
      throw ArgumentError.value(
        credential,
        'credential',
        'Google credential cannot be empty',
      );
    }

    final response = await _httpClient.post(
      Uri.parse('${Endpoints.baseUrl}${Endpoints.googleLoginUrl}'),
      body: jsonEncode({'credential': normalizedCredential}),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': ApiConstants.userAgent,
      },
    );
    printData('Google Login Response', response.body);
    return response;
  }

  Future<GoogleSignInAccount> _authenticateGoogleUser({
    bool retryOnReauthFailure = true,
  }) async {
    try {
      return await googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      final description = error.description?.toLowerCase() ?? '';
      final shouldRetry =
          retryOnReauthFailure &&
          error.code == GoogleSignInExceptionCode.canceled &&
          description.contains('reauth failed');
      if (!shouldRetry) rethrow;
      await _clearGoogleSession();
      return _authenticateGoogleUser(retryOnReauthFailure: false);
    }
  }

  Future<http.Response> signInWithApple() async {
    try {
      return await exchangeAppleCredential(await getAppleCredential());
    } on SocialAuthCancelledException {
      rethrow;
    } catch (error) {
      return Future.error(handleHttpError(error));
    }
  }

  Future<AppleSignInPayload> getAppleCredential() async {
    try {
      final rawNonce = _generateNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _sha256(rawNonce),
      );
      final identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('Apple sign-in did not return an identity token.');
      }
      final name = [appleCredential.givenName, appleCredential.familyName]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join(' ');

      return AppleSignInPayload(
        credential: identityToken,
        nonce: rawNonce,
        name: name.isEmpty ? null : name,
        authorizationCode: appleCredential.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SocialAuthCancelledException();
      }
      throw AppleSignInException(error.message);
    } catch (error) {
      if (error is SocialAuthCancelledException) rethrow;
      if (error is AppleSignInException) rethrow;
      throw AppleSignInException(error.toString());
    }
  }

  Future<http.Response> exchangeAppleCredential(
    AppleSignInPayload apple,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('${Endpoints.baseUrl}${Endpoints.appleLoginUrl}'),
      body: jsonEncode(apple.toJson()),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': ApiConstants.userAgent,
      },
    );
    printData('Apple Login Response', response.body);
    return response;
  }

  Future<void> signOutSocials() async {
    try {
      await googleSignIn.signOut();
    } catch (_) {}
  }

  Future<void> _clearGoogleSession() async {
    try {
      await googleSignIn.disconnect();
    } catch (_) {
      await googleSignIn.signOut();
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();
}

/// Checks the non-secret claims needed by the Idile API before the credential
/// is sent. Signature verification remains the API's responsibility.
void validateGoogleIdToken(
  String token, {
  required String expectedAudience,
  DateTime? now,
}) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw const GoogleIdTokenException(
      'Google returned an invalid sign-in credential. Please try again.',
    );
  }

  Map<String, dynamic> payload;
  try {
    final decoded = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    payload = Map<String, dynamic>.from(jsonDecode(decoded) as Map);
  } catch (_) {
    throw const GoogleIdTokenException(
      'Google returned an invalid sign-in credential. Please try again.',
    );
  }

  final issuer = payload['iss']?.toString();
  if (issuer != 'accounts.google.com' &&
      issuer != 'https://accounts.google.com') {
    throw const GoogleIdTokenException(
      'Google returned an invalid sign-in credential. Please try again.',
    );
  }

  final audienceClaim = payload['aud'];
  final audiences = audienceClaim is List
      ? audienceClaim.map((value) => value.toString()).toSet()
      : {if (audienceClaim != null) audienceClaim.toString()};
  if (expectedAudience.isEmpty || !audiences.contains(expectedAudience)) {
    throw const GoogleIdTokenException(
      'Google sign-in is configured for a different app. Please update the Google OAuth client ID.',
    );
  }

  final expiresAtSeconds = switch (payload['exp']) {
    final num value => value.toInt(),
    final String value => int.tryParse(value),
    _ => null,
  };
  final currentSeconds =
      (now ?? DateTime.now().toUtc()).millisecondsSinceEpoch ~/ 1000;
  if (expiresAtSeconds == null || expiresAtSeconds <= currentSeconds) {
    throw const GoogleIdTokenException(
      'The Google sign-in credential expired. Please try again.',
    );
  }
}

class GoogleIdTokenException implements Exception {
  const GoogleIdTokenException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppleSignInException implements Exception {
  const AppleSignInException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SocialAuthCancelledException implements Exception {
  const SocialAuthCancelledException();
}
