import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseController<T> extends StateNotifier<AsyncValue<T>> {
  BaseController(T initialData) : super(AsyncValue.data(initialData));

  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}
