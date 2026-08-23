import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(true) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Always treat as authenticated admin
    state = true;
  }

  Future<bool> login(String email, String password) async {
    state = true;
    return true;
  }

  Future<void> logout() async {
    state = true; // Prevents logging out in the admin panel
  }
}
