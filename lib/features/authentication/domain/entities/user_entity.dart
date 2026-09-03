import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, fullName, phone, email, avatarUrl];

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      fullName: json['fullName'] ?? json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'avatar_url': avatarUrl,
    };
  }
}
