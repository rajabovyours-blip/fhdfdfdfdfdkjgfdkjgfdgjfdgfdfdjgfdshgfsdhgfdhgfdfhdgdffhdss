import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:milliy_metr/features/authentication/domain/entities/token_entity.dart';

part 'token_model.freezed.dart';
part 'token_model.g.dart';

@freezed
class TokenModel with _$TokenModel {
  const TokenModel._();

  const factory TokenModel({
    required String accessToken,
    String? refreshToken,
  }) = _TokenModel;

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);

  TokenEntity toEntity() => TokenEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
