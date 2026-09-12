import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/shared/endpoint.dart';
import 'package:stylclick/shared/models/api_model.dart';

/// Central base service.
/// All protected calls should use [authHeaders].
class ApiService {
  static ApiService? _instance;

  ApiService._();

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  // ── Token helpers ─────────────────────────────────────────────────────

  static Map<String, String> get baseHeaders => {
        "Accept": "application/json",
      };

  /// Reads the token directly from SharedPreferences and nb_utils.
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("access_token") ?? '';
    if (token.isEmpty) {
      token = getStringAsync("access_token");
      if (token.isNotEmpty) {
        await prefs.setString("access_token", token);
      }
    }
    log('[API] Token read: ${token.isEmpty ? "EMPTY" : "present (${token.length} chars)"}');
    return {
      "Accept": "application/json",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static const Duration defaultTimeout = Duration(seconds: 15);
  static const int maxRetries = 1;

  static bool _isWarmedUp = false;

  /// Background ping to wake up backend server instance immediately on app/auth load
  void warmUpBackend() {
    if (_isWarmedUp) return;
    _isWarmedUp = true;
    try {
      final url = Uri.parse(baseUrl + "products");
      log('[API] Background server warm-up initiated: $url');
      http.get(url, headers: baseHeaders).timeout(const Duration(seconds: 15)).catchError((e) {
        log('[API] Warm-up ping finished: $e');
        return http.Response('', 500);
      });
    } catch (e) {
      log('[API] Warm-up exception ignored: $e');
    }
  }

  Future<http.Response> _executeWithRetry(Future<http.Response> Function() requestFn) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await requestFn().timeout(defaultTimeout);
      } on TimeoutException {
        if (attempt > maxRetries) rethrow;
        log('[API] Attempt $attempt timed out. Retrying automatically...');
      } on SocketException {
        if (attempt > maxRetries) rethrow;
        log('[API] Attempt $attempt network socket error. Retrying automatically...');
      }
    }
  }

  // ── Generic request helpers ───────────────────────────────────────────

  /// Upload multiple files via multipart POST. Returns the full decoded response body.
  Future<ApiResponse<dynamic>> postMultipart(
    String path, {
    required List<String> filePaths,
    String fileField = 'images',
    Map<String, String> fields = const {},
  }) async {
    final apiResponse = ApiResponse<dynamic>();
    try {
      final url = Uri.parse(baseUrl + path);
      final headers = await _authHeaders();
      log('[API] MULTIPART POST $url | files: $filePaths');

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..fields.addAll(fields);

      for (final filePath in filePaths) {
        request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      }

      final streamed = await request.send().timeout(defaultTimeout);
      final res = await http.Response.fromStream(streamed);
      log('[API] Status: ${res.statusCode} | Body: ${res.body}');

      dynamic data;
      try { data = json.decode(res.body); } catch (_) {}

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bool isExplicitFailure = data is Map && data.containsKey('status') && (data['status'] == false || data['status'] == 0 || data['status'] == 'false');
        if (isExplicitFailure) {
          apiResponse.status = false;
          apiResponse.message = _parseErrorMessage(data, res.statusCode);
        } else {
          apiResponse.data = data ?? res.body;
          apiResponse.status = true;
          apiResponse.message = data is Map && data.containsKey('message') ? data['message'].toString() : null;
        }
      } else {
        apiResponse.status = false;
        apiResponse.message = _parseErrorMessage(data, res.statusCode);
      }
    } on SocketException {
      apiResponse.status = false;
      apiResponse.message = 'No internet connection.';
    } on TimeoutException {
      apiResponse.status = false;
      apiResponse.message = 'Upload timed out. Please try again.';
    } catch (e) {
      apiResponse.status = false;
      apiResponse.message = e.toString();
    }
    return apiResponse;
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    required dynamic body,
    bool authenticated = false,
    T Function(dynamic)? transform,
  }) async {
    transform ??= (r) => r as T;
    final apiResponse = ApiResponse<T>();

    try {
      final url = baseUrl + path;
      final headers = authenticated ? await _authHeaders() : baseHeaders;
      log('[API] POST $url | body: $body');
      log('[API] Headers: $headers');

      Object? reqBody = body;
      Map<String, String> reqHeaders = Map<String, String>.from(headers);
      reqHeaders['Content-Type'] = 'application/json';
      if (body is Map || body is List) {
        reqBody = json.encode(body);
      }

      final res = await _executeWithRetry(
        () => http.post(
          Uri.parse(url),
          headers: reqHeaders,
          body: reqBody,
        ),
      );

      log('[API] Status: ${res.statusCode} | Body: ${res.body}');

      dynamic data;
      try {
        data = json.decode(res.body);
      } catch (_) {}

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bool isExplicitFailure = data is Map && data.containsKey('status') && (data['status'] == false || data['status'] == 0 || data['status'] == 'false');
        if (isExplicitFailure) {
          apiResponse.status = false;
          apiResponse.message = _parseErrorMessage(data, res.statusCode);
        } else {
          apiResponse.data = transform(data ?? res.body);
          apiResponse.status = true;
          apiResponse.message = data is Map && data.containsKey('message')
              ? data['message'].toString()
              : null;
        }
      } else {
        apiResponse.status = false;
        apiResponse.message = _parseErrorMessage(data, res.statusCode);
      }
    } on SocketException {
      apiResponse.status = false;
      apiResponse.message = 'No internet connection. Please check your network.';
    } on TimeoutException {
      apiResponse.status = false;
      apiResponse.message = 'Connection timed out. Please try again.';
    } catch (e) {
      apiResponse.status = false;
      apiResponse.message = e.toString();
    }

    return apiResponse;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    bool authenticated = true,
    T Function(dynamic)? transform,
  }) async {
    transform ??= (r) => r as T;
    final apiResponse = ApiResponse<T>();

    try {
      final url = baseUrl + path;
      log('[API] GET $url');
      final headers = authenticated ? await _authHeaders() : baseHeaders;

      final res = await _executeWithRetry(
        () => http.get(
          Uri.parse(url),
          headers: headers,
        ),
      );

      log('[API] Status: ${res.statusCode} | Body: ${res.body}');

      dynamic data;
      try {
        data = json.decode(res.body);
      } catch (_) {}

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bool isExplicitFailure = data is Map && data.containsKey('status') && (data['status'] == false || data['status'] == 0 || data['status'] == 'false');
        if (isExplicitFailure) {
          apiResponse.status = false;
          apiResponse.message = _parseErrorMessage(data, res.statusCode);
        } else {
          apiResponse.data = transform(data ?? res.body);
          apiResponse.status = true;
        }
      } else {
        apiResponse.status = false;
        apiResponse.message = _parseErrorMessage(data, res.statusCode);
      }
    } on SocketException {
      apiResponse.status = false;
      apiResponse.message = 'No internet connection. Please check your network.';
    } on TimeoutException {
      apiResponse.status = false;
      apiResponse.message = 'Connection timed out. Please try again.';
    } catch (e) {
      apiResponse.status = false;
      apiResponse.message = e.toString();
    }

    return apiResponse;
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    required dynamic body,
    bool authenticated = true,
    T Function(dynamic)? transform,
  }) async {
    transform ??= (r) => r as T;
    final apiResponse = ApiResponse<T>();

    try {
      final url = baseUrl + path;
      final headers = authenticated ? await _authHeaders() : baseHeaders;
      log('[API] PATCH $url | body: $body');

      Object? reqBody = body;
      Map<String, String> reqHeaders = Map<String, String>.from(headers);
      if (body is Map && body is! Map<String, String>) {
        reqBody = json.encode(body);
        reqHeaders['Content-Type'] = 'application/json';
      }

      final res = await _executeWithRetry(
        () => http.patch(
          Uri.parse(url),
          headers: reqHeaders,
          body: reqBody,
        ),
      );

      log('[API] Status: ${res.statusCode} | Body: ${res.body}');

      dynamic data;
      try {
        data = json.decode(res.body);
      } catch (_) {}

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bool isExplicitFailure = data is Map && data.containsKey('status') && (data['status'] == false || data['status'] == 0 || data['status'] == 'false');
        if (isExplicitFailure) {
          apiResponse.status = false;
          apiResponse.message = _parseErrorMessage(data, res.statusCode);
        } else {
          apiResponse.data = transform(data ?? res.body);
          apiResponse.status = true;
          apiResponse.message = data is Map && data.containsKey('message')
              ? data['message'].toString()
              : null;
        }
      } else {
        apiResponse.status = false;
        apiResponse.message = _parseErrorMessage(data, res.statusCode);
      }
    } on SocketException {
      apiResponse.status = false;
      apiResponse.message = 'No internet connection. Please check your network.';
    } on TimeoutException {
      apiResponse.status = false;
      apiResponse.message = 'Connection timed out. Please try again.';
    } catch (e) {
      apiResponse.status = false;
      apiResponse.message = e.toString();
    }

    return apiResponse;
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    bool authenticated = true,
    T Function(dynamic)? transform,
  }) async {
    transform ??= (r) => r as T;
    final apiResponse = ApiResponse<T>();

    try {
      final url = baseUrl + path;
      log('[API] DELETE $url');
      final headers = authenticated ? await _authHeaders() : baseHeaders;

      final res = await _executeWithRetry(
        () => http.delete(
          Uri.parse(url),
          headers: headers,
        ),
      );

      log('[API] Status: ${res.statusCode} | Body: ${res.body}');

      dynamic data;
      try {
        data = json.decode(res.body);
      } catch (_) {}

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bool isExplicitFailure = data is Map && data.containsKey('status') && (data['status'] == false || data['status'] == 0 || data['status'] == 'false');
        if (isExplicitFailure) {
          apiResponse.status = false;
          apiResponse.message = _parseErrorMessage(data, res.statusCode);
        } else {
          apiResponse.data = transform(data ?? res.body);
          apiResponse.status = true;
          apiResponse.message = data is Map && data.containsKey('message')
              ? data['message'].toString()
              : null;
        }
      } else {
        apiResponse.status = false;
        apiResponse.message = _parseErrorMessage(data, res.statusCode);
      }
    } on SocketException {
      apiResponse.status = false;
      apiResponse.message = 'No internet connection. Please check your network.';
    } on TimeoutException {
      apiResponse.status = false;
      apiResponse.message = 'Connection timed out. Please try again.';
    } catch (e) {
      apiResponse.status = false;
      apiResponse.message = e.toString();
    }

    return apiResponse;
  }


  String _parseErrorMessage(dynamic data, int statusCode) {
    if (data is Map) {
      try {
        // 1. Check "error" key (which could be List, String, or Map)
        if (data.containsKey('error')) {
          final errorVal = data['error'];
          if (errorVal is List && errorVal.isNotEmpty) {
            return errorVal.map((e) => e.toString().replaceAll('"', '')).join(', ');
          }
          if (errorVal is String) {
            return errorVal.replaceAll('"', '');
          }
          if (errorVal is Map) {
            final errorMap = errorVal;
            if (errorMap.containsKey('response') && errorMap['response'] is Map) {
              final responseMap = errorMap['response'] as Map;
              if (responseMap.containsKey('body') && responseMap['body'] is Map) {
                final bodyMap = responseMap['body'] as Map;
                if (bodyMap.containsKey('errors') && bodyMap['errors'] is List) {
                  final errorsList = bodyMap['errors'] as List;
                  if (errorsList.isNotEmpty && errorsList[0] is Map) {
                    final firstError = errorsList[0] as Map;
                    if (firstError.containsKey('message')) {
                      final nestedMsg = firstError['message'].toString().replaceAll('"', '');
                      final mainMsg = data.containsKey('message') ? data['message'].toString().replaceAll('"', '') : '';
                      if (mainMsg.isNotEmpty && mainMsg != nestedMsg) {
                        return "$mainMsg: $nestedMsg";
                      }
                      return nestedMsg;
                    }
                  }
                }
              }
            }
            if (errorMap.containsKey('message')) {
              final errMessage = errorMap['message'].toString().replaceAll('"', '');
              final mainMsg = data.containsKey('message') ? data['message'].toString().replaceAll('"', '') : '';
              if (mainMsg.isNotEmpty && mainMsg != errMessage) {
                return "$mainMsg: $errMessage";
              }
              return errMessage;
            }
          }
        }

        // 2. Check "errors" key (which could be List, Map, or String)
        if (data.containsKey('errors')) {
          final errorsVal = data['errors'];
          if (errorsVal is List && errorsVal.isNotEmpty) {
            return errorsVal.map((e) => e.toString().replaceAll('"', '')).join(', ');
          }
          if (errorsVal is Map) {
            final List<String> messages = [];
            errorsVal.forEach((key, value) {
              if (value is List) {
                messages.add("$key: ${value.map((v) => v.toString().replaceAll('"', '')).join(', ')}");
              } else {
                messages.add("$key: ${value.toString().replaceAll('"', '')}");
              }
            });
            if (messages.isNotEmpty) {
              return messages.join('\n');
            }
          }
          if (errorsVal is String) {
            return errorsVal.replaceAll('"', '');
          }
        }
      } catch (e) {
        log('[API] Error parsing nested error: $e');
      }

      // 3. Fall back to standard "message" key
      if (data.containsKey('message')) {
        return data['message'].toString().replaceAll('"', '');
      }
    }
    return 'Request failed ($statusCode)';
  }
}
