import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepositoryImpl();
  ref.onDispose(() {});
  return repo;
});

/// Holds the current authenticated user (or null). Drives login-gated routing.
class AuthNotifier extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() async {
    return _repo.checkCurrentUser();
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repo.login(email, password);
      state = AsyncData(user);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.clearToken();
    state = const AsyncData(null);
  }

  String? get errorMessage {
    final err = state.error;
    if (err == null) return null;
    return err.toString().replaceAll('Exception: ', '');
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).valueOrNull != null;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).valueOrNull?.isAdmin ?? false;
});

/// Manages the admin user-management list (fetch/create/update/delete).
class AdminUsersNotifier extends AsyncNotifier<List<User>> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<List<User>> build() async => [];

  Future<void> fetchUsers() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repo.getUsers());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<bool> createUser(String email, String name, String password, String role) async {
    try {
      final newUser = await _repo.registerUser(email, name, password, role);
      state = AsyncData([...state.valueOrNull ?? [], newUser]);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateUserDetails(int id, {String? name, String? role, bool? isActive, String? password}) async {
    try {
      await _repo.updateUser(id, name: name, role: role, isActive: isActive, password: password);
      await fetchUsers();
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _repo.deleteUser(id);
      state = AsyncData((state.valueOrNull ?? []).where((u) => u.id != id).toList());
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  String? get errorMessage {
    final err = state.error;
    if (err == null) return null;
    return err.toString().replaceAll('Exception: ', '');
  }
}

final adminUsersProvider = AsyncNotifierProvider<AdminUsersNotifier, List<User>>(AdminUsersNotifier.new);
