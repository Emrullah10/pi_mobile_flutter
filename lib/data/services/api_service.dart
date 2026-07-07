import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

/// Low-level HTTP client for Raspberry Pi backend
class ApiService {
  final http.Client _client;
  final String? _overrideUrl;

  String get _baseUrl => _overrideUrl ?? ApiConstants.baseUrl;

  ApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _overrideUrl = baseUrl;

  // Ortak başlıkları (Header) ve JWT Token'ı hazırlayan yardımcı metot
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw ApiException(
        'GET $endpoint failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (e) {
      developer.log('API ERROR: $endpoint → $e', name: 'ApiService');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// GET request returning a list
  Future<List<dynamic>> getList(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw ApiException(
        'GET $endpoint failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (e) {
      developer.log('API ERROR: $endpoint → $e', name: 'ApiService');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw ApiException(
        'POST $endpoint failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (e) {
      developer.log('API ERROR: $endpoint → $e', name: 'ApiService');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
