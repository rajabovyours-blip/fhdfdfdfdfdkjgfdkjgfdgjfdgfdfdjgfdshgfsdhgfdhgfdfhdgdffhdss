import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(false) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final token = await _repository.getToken();
    state = token != null;
  }

  Future<bool> login(String email, String password) async {
    final success = await _repository.login(email, password);
    if (success) {
      state = true;
    }
    return success;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = false;
  }
}
