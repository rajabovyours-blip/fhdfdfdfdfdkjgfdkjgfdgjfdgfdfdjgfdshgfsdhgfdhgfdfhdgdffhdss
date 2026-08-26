import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminModerationQueueProvider =
    Provider<AsyncValue<List<dynamic>>>((ref) => const AsyncValue.data([]));
