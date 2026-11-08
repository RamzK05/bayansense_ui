import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _httpClient = http.Client();

  // Stored JWT token from login/register
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  // Common headers
  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final base = ApiConfig.baseUrl;
    final fullUrl = '$base$path';

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map((k, v) => MapEntry(k, v.toString()));
      return Uri.parse(fullUrl).replace(queryParameters: stringParams);
    }

    return Uri.parse(fullUrl);
  }

  // --- GET ---
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(path, queryParams);
      final response = await _httpClient
          .get(uri, headers: _buildHeaders())
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection or server unreachable.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}');
    }
  }

  // --- POST ---
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(path);
      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection or server unreachable.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}');
    }
  }

  // --- PATCH ---
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(path);
      final response = await _httpClient
          .patch(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection or server unreachable.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}');
    }
  }

  // --- DELETE ---
  Future<dynamic> delete(String path) async {
    try {
      final uri = _buildUri(path);
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders())
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection or server unreachable.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}');
    }
  }

  // Response parser & error interpreter
  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic jsonBody;

    if (response.body.isNotEmpty) {
      try {
        jsonBody = jsonDecode(response.body);
      } catch (_) {
        jsonBody = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return jsonBody;
    }

    // Extract error message from FastAPI default {"detail": "..."}
    String errorMessage = 'Server error ($statusCode)';
    if (jsonBody is Map && jsonBody.containsKey('detail')) {
      final detail = jsonBody['detail'];
      if (detail is String) {
        errorMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // FastAPI validation error array
        errorMessage = detail.map((e) => e['msg'] ?? e.toString()).join(', ');
      }
    }

    switch (statusCode) {
      case 400:
        throw ApiException(message: errorMessage, statusCode: 400, details: jsonBody);
      case 401:
        throw ApiException(message: 'Session expired or invalid credentials. Please log in again.', statusCode: 401);
      case 403:
        throw ApiException(message: 'Access denied: You do not have permission for this action.', statusCode: 403);
      case 404:
        throw ApiException(message: errorMessage.isNotEmpty ? errorMessage : 'Resource not found.', statusCode: 404);
      case 422:
        throw ApiException(message: 'Validation error: $errorMessage', statusCode: 422, details: jsonBody);
      case 500:
      default:
        throw ApiException(message: 'Server error: Please try again later.', statusCode: statusCode, details: jsonBody);
    }
  }
}
