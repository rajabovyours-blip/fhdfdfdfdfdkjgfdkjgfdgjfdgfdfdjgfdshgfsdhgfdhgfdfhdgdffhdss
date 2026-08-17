import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, fullName, phone, email, avatarUrl];
}
