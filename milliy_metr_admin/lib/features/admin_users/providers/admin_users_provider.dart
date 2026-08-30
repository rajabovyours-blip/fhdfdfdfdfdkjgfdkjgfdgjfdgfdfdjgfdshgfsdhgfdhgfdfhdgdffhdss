import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class AdminUser {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'],
    );
  }
}

final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/admin/users/');
  
  if (response.statusCode == 200) {
    final List data = response.data['data'];
    return data.map((json) => AdminUser.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load admin users');
  }
});

final createAdminProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return (String username, String fullName, String password, String role) async {
    await dio.post('/admin/users/', data: {
      'username': username,
      'full_name': fullName,
      'password': password,
      'role': role,
    });
    ref.invalidate(adminUsersProvider);
  };
});

final toggleAdminStatusProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return (String id, bool isActive) async {
    await dio.patch('/admin/users/$id/status', data: {
      'is_active': isActive,
    });
    ref.invalidate(adminUsersProvider);
  };
});
