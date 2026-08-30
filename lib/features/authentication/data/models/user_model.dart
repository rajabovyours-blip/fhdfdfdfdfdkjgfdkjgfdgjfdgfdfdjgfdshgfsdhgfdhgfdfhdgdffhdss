import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:milliy_metr/features/authentication/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String fullName,
    required String phone,
    String? email,
    String? avatarUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
        id: id,
        fullName: fullName,
        phone: phone,
        email: email,
        avatarUrl: avatarUrl,
      );
}
