import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/constants/api_constants.dart';
import 'package:idile_mobile_app/core/network/api_exception.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/core/services/session_events.dart';
import 'package:idile_mobile_app/features/auth/data/service/device_binding_service.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    SessionStore? store,
    DeviceBindingService? deviceBindingService,
  }) : _client = client ?? http.Client(),
       store = store ?? SessionStore(),
       _deviceBindingService = deviceBindingService ?? DeviceBindingService();

  final http.Client _client;
  final SessionStore store;
  final DeviceBindingService _deviceBindingService;
  Future<String?>? _refreshing;

  Future<T> get<T>(
    String path,
    T Function(dynamic) decode, {
    bool auth = true,
  }) => request(path, decode, auth: auth);

  Future<T> getEnvelope<T>(
    String path,
    T Function(dynamic) decode, {
    bool auth = true,
  }) => request(path, decode, auth: auth, unwrapData: false);

  Future<T> post<T>(
    String path,
    T Function(dynamic) decode, {
    Object? body,
    bool auth = true,
    bool dpop = false,
    bool unwrapData = true,
  }) => request(
    path,
    decode,
    method: 'POST',
    body: body,
    auth: auth,
    dpop: dpop,
    unwrapData: unwrapData,
  );

  Future<T> put<T>(String path, T Function(dynamic) decode, {Object? body}) =>
      request(path, decode, method: 'PUT', body: body);

  Future<T> patch<T>(String path, T Function(dynamic) decode, {Object? body}) =>
      request(path, decode, method: 'PATCH', body: body);

  Future<T> delete<T>(String path, T Function(dynamic) decode) =>
      request(path, decode, method: 'DELETE');

  Future<T> request<T>(
    String path,
    T Function(dynamic) decode, {
    String method = 'GET',
    Object? body,
    bool auth = true,
    bool retry = true,
    bool dpop = false,
    bool unwrapData = true,
  }) async {
    final uri = _apiUri(path);
    final token = auth ? await store.accessToken : null;
    final deviceBound = (auth || dpop) ? await store.isDeviceBound : false;
    final needsDpop = deviceBound && (auth || dpop);
    final proof = needsDpop
        ? await _deviceBindingService.createDpopProof(
            method: method,
            uri: uri,
            accessToken: auth ? token : null,
          )
        : null;
    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': ApiConstants.userAgent,
      if (body != null) 'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = '${deviceBound ? 'DPoP' : 'Bearer'} $token';
    }
    if (proof != null) headers['DPoP'] = proof;
    final response = await _client.send(
      http.Request(method, uri)
        ..headers.addAll(headers)
        ..body = body == null ? '' : jsonEncode(body),
    );
    final streamed = await http.Response.fromStream(response);
    printData('$method $path Response', streamed.body);
    final payload = streamed.body.isEmpty ? null : jsonDecode(streamed.body);
    if (streamed.statusCode == 401 && auth && retry) {
      final refreshed = await _refresh();
      if (refreshed != null) {
        return request(
          path,
          decode,
          method: method,
          body: body,
          auth: auth,
          retry: false,
          dpop: dpop,
          unwrapData: unwrapData,
        );
      }
    }
    if (streamed.statusCode == 403 &&
        auth &&
        deviceBound &&
        _isRevokedDeviceError(payload)) {
      await store.clear();
      await _deviceBindingService.deleteKey();
      SessionEvents.notifyDeviceRevoked();
    }
    if (streamed.statusCode < 200 ||
        streamed.statusCode >= 300 ||
        (payload is Map && payload['success'] == false)) {
      final error = payload is Map ? payload['error'] : null;
      throw ApiException(
        error is Map
            ? '${error['message'] ?? 'Something went wrong'}'
            : 'Request failed',
        statusCode: streamed.statusCode,
        code: error is Map ? error['code']?.toString() : null,
      );
    }
    final data = unwrapData && payload is Map && payload.containsKey('data')
        ? payload['data']
        : payload;
    return decode(data);
  }

  Future<T> multipart<T>(
    String path,
    T Function(dynamic) decode, {
    required Map<String, String> fields,
    List<int>? fileBytes,
    String? fileName,
    String method = 'POST',
    String? fileContentType,
  }) async {
    final uri = _apiUri(path);
    final token = await store.accessToken;
    final deviceBound = await store.isDeviceBound;
    final proof = deviceBound && token != null
        ? await _deviceBindingService.createDpopProof(
            method: method,
            uri: uri,
            accessToken: token,
          )
        : null;
    final request = http.MultipartRequest(method, uri)
      ..headers['Accept'] = 'application/json'
      ..headers['User-Agent'] = ApiConstants.userAgent
      ..fields.addAll(fields);
    if (token != null) {
      request.headers['Authorization'] =
          '${deviceBound ? 'DPoP' : 'Bearer'} $token';
    }
    if (proof != null) request.headers['DPoP'] = proof;
    if (fileBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: fileContentType == null
              ? null
              : MediaType.parse(fileContentType),
        ),
      );
    }
    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    printData('$method $path Multipart Response', response.body);
    final payload = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        (payload is Map && payload['success'] == false)) {
      final error = payload is Map ? payload['error'] : null;
      throw ApiException(
        error is Map
            ? '${error['message'] ?? 'Upload failed'}'
            : 'Upload failed',
        statusCode: response.statusCode,
      );
    }
    final data = payload is Map && payload.containsKey('data')
        ? payload['data']
        : payload;
    return decode(data);
  }

  Future<String?> _refresh() async {
    if (_refreshing != null) return _refreshing;
    _refreshing = _performRefresh();
    try {
      return await _refreshing;
    } finally {
      _refreshing = null;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await store.refreshToken;
    if (refreshToken == null) return null;
    final deviceBound = await store.isDeviceBound;
    try {
      final tokens = await post<Map<String, dynamic>>(
        '/auth/refresh',
        (value) => Map<String, dynamic>.from(value as Map),
        body: {'refreshToken': refreshToken},
        auth: false,
        dpop: deviceBound,
      );
      final access = tokens['accessToken']?.toString();
      final refresh = tokens['refreshToken']?.toString();
      if (access == null || refresh == null) return null;
      await store.save(accessToken: access, refreshToken: refresh);
      return access;
    } catch (_) {
      await store.clear();
      return null;
    }
  }
}

bool _isRevokedDeviceError(dynamic payload) {
  if (payload is! Map) return false;
  final error = payload['error'];
  if (error is! Map) return false;
  final description = '${error['code'] ?? ''} ${error['message'] ?? ''}'
      .toLowerCase();
  return description.contains('device') && description.contains('revok');
}

Uri _apiUri(String path) {
  final base = ApiConstants.baseUrl.replaceFirst(RegExp(r'/+$'), '');
  final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
  return Uri.parse('$base/$normalizedPath');
}
