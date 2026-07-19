import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';

/// Low-level HTTP client for the Pi backend, shared by all feature repositories.
class ApiClient {
  final http.Client _client;
  final String? _overrideUrl;

  String get _baseUrl => _overrideUrl ?? ApiConstants.baseUrl;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _overrideUrl = baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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
      developer.log('API ERROR: $endpoint → $e', name: 'ApiClient');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

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
      developer.log('API ERROR: $endpoint → $e', name: 'ApiClient');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

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
      developer.log('API ERROR: $endpoint → $e', name: 'ApiClient');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw ApiException(
        'PUT $endpoint failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (e) {
      developer.log('API ERROR: $endpoint → $e', name: 'ApiClient');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw ApiException(
        'DELETE $endpoint failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (e) {
      developer.log('API ERROR: $endpoint → $e', name: 'ApiClient');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
