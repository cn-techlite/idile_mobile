class ApiConstants {
  const ApiConstants._();

  static const environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'test',
  );

  /// Optional one-off override, useful for local development and CI.
  static const _baseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const productionBaseUrl = String.fromEnvironment(
    'PRODUCTION_BASE_URL',
    defaultValue: 'https://api.idile.com.ng/v1/',
  );
  static const liveBaseUrl = String.fromEnvironment(
    'LIVE_BASE_URL',
    defaultValue: 'https://api.idile.com.ng/v1/',
  );
  static const testBaseUrl = String.fromEnvironment(
    'TEST_BASE_URL',
    defaultValue: 'https://api.idile.com.ng/v1/',
  );

  static String get baseUrl {
    final configuredUrl = _baseUrlOverride.isNotEmpty
        ? _baseUrlOverride
        : switch (environment.toLowerCase()) {
            'production' => productionBaseUrl,
            'live' => liveBaseUrl,
            _ => testBaseUrl,
          };
    return '${configuredUrl.replaceFirst(RegExp(r'/+$'), '')}/';
  }

  static const userAgent = 'IdileMobileApp/1.0.0 (Flutter)';

  /// OAuth client IDs used for Google sign-in.
  ///
  /// The web client ID must match the audience configured by the Idile API.
  /// It is safe to ship an OAuth client ID in the app, but never a client
  /// secret. Environment values keep CI and local builds configurable.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '488170201737-v5pequj4q911cfbrfdbh3dst6tppq973.apps.googleusercontent.com',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '488170201737-6gc87noas1b5585gg77bljas61pd6tp6.apps.googleusercontent.com',
  );
}
