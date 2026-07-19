import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();

  Future<User> login(String email, String password);
  Future<User?> checkCurrentUser();

  Future<List<User>> getUsers();
  Future<User> registerUser(String email, String name, String password, String role);
  Future<void> updateUser(int id, {String? name, String? role, bool? isActive, String? password});
  Future<void> deleteUser(int id);
}
