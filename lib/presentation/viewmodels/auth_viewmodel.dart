import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _users = [];

  AuthViewModel({AuthService? authService})
      : _authService = authService ?? AuthService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isUser => _currentUser?.isUser ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<User> get users => _users;

  // Uygulama başlarken token geçerliliğini kontrol et
  Future<void> checkAuth() async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.checkCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  // --- KULLANICI YÖNETİMİ (ADMIN ONLY) ---

  // Tüm kullanıcıları getir
  Future<void> fetchUsers() async {
    _setLoading(true);
    _clearError();
    try {
      _users = await _authService.getUsers();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Yeni kullanıcı oluştur
  Future<bool> createUser(String email, String name, String password, String role) async {
    _setLoading(true);
    _clearError();
    try {
      final newUser = await _authService.registerUser(email, name, password, role);
      _users.add(newUser);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı güncelle
  Future<bool> updateUserDetails(int id, {String? name, String? role, bool? isActive, String? password}) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.updateUser(id, name: name, role: role, isActive: isActive, password: password);
      // Yerel listeyi güncelle
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        // Yeniden çekmek en güvenlisi
        await fetchUsers();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı sil
  Future<bool> deleteUser(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı Girişi
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.login(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Çıkış Yap
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.clearToken();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
