import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_state.freezed.dart';

@freezed
class FeatureState<T> with _$FeatureState<T> {
  const factory FeatureState.initial() = _Initial<T>;
  const factory FeatureState.loading() = _Loading<T>;
  const factory FeatureState.loaded(T data) = _Loaded<T>;
  const factory FeatureState.error(String message) = _Error<T>;
}
