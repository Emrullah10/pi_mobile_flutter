import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  final String? _overrideUrl;
  final http.Client _client;

  String get _baseUrl => _overrideUrl ?? ApiConstants.baseUrl;

  AuthService({
    String? baseUrl,
    http.Client? client,
  })  : _overrideUrl = baseUrl,
        _client = client ?? http.Client();

  static const String _tokenKey = 'auth_token';

  // Token'ı kaydet
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Token'ı oku
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Token'ı sil (Çıkış yap)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Giriş yap
  Future<User> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      await saveToken(token);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Giriş yapılamadı.');
    }
  }

  // Token geçerliliğini kontrol et & Kullanıcı detayını getir
  Future<User?> checkCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await _client.get(
      Uri.parse('$_baseUrl/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromJson(data);
    } else {
      // Token geçersizse temizle
      await clearToken();
      return null;
    }
  }

  // --- KULLANICI YÖNETİMİ (ADMIN ONLY) ---

  // Tüm kullanıcıları listele
  Future<List<User>> getUsers() async {
    final token = await getToken();
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/auth/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Kullanıcılar yüklenemedi.');
    }
  }

  // Yeni kullanıcı kaydet
  Future<User> registerUser(String email, String name, String password, String role) async {
    final token = await getToken();
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'name': name,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Kullanıcı oluşturulamadı.');
    }
  }

  // Kullanıcı güncelle (Aktiflik, İsim, Rol, Şifre)
  Future<void> updateUser(int id, {String? name, String? role, bool? isActive, String? password}) async {
    final token = await getToken();
    final response = await _client.put(
      Uri.parse('$_baseUrl/api/auth/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
        if (password != null && password.isNotEmpty) 'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Kullanıcı güncellenemedi.');
    }
  }

  // Kullanıcı sil
  Future<void> deleteUser(int id) async {
    final token = await getToken();
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/auth/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Kullanıcı silinemedi.');
    }
  }
}
