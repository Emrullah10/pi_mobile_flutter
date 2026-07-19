import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static const String _tokenKey = 'auth_token';

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final data = await _apiClient.post('/api/auth/login', body: {'email': email, 'password': password});
      final token = data['token'] as String;
      await saveToken(token);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw Exception(_extractError(e) ?? 'Giriş yapılamadı.');
    }
  }

  @override
  Future<User?> checkCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final data = await _apiClient.get('/api/auth/me');
      return User.fromJson(data);
    } on ApiException {
      await clearToken();
      return null;
    }
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      final list = await _apiClient.getList('/api/auth/users');
      return list.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw Exception(_extractError(e) ?? 'Kullanıcılar yüklenemedi.');
    }
  }

  @override
  Future<User> registerUser(String email, String name, String password, String role) async {
    try {
      final data = await _apiClient.post('/api/auth/register', body: {
        'email': email,
        'name': name,
        'password': password,
        'role': role,
      });
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw Exception(_extractError(e) ?? 'Kullanıcı oluşturulamadı.');
    }
  }

  @override
  Future<void> updateUser(int id, {String? name, String? role, bool? isActive, String? password}) async {
    try {
      await _apiClient.put('/api/auth/users/$id', body: {
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
        if (password != null && password.isNotEmpty) 'password': password,
      });
    } on ApiException catch (e) {
      throw Exception(_extractError(e) ?? 'Kullanıcı güncellenemedi.');
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _apiClient.delete('/api/auth/users/$id');
    } on ApiException catch (e) {
      throw Exception(_extractError(e) ?? 'Kullanıcı silinemedi.');
    }
  }

  String? _extractError(ApiException e) {
    try {
      if (e.body == null || e.body!.isEmpty) return null;
      final decoded = jsonDecode(e.body!) as Map<String, dynamic>;
      return decoded['error'] as String?;
    } catch (_) {
      return null;
    }
  }
}
