import 'dart:async';

/// Global event bus for authentication events.
class AuthEventBus {
  static final StreamController<AuthEvent> _controller = StreamController<AuthEvent>.broadcast();

  static Stream<AuthEvent> get stream => _controller.stream;

  static void emit(AuthEvent event) {
    _controller.add(event);
  }

  static void dispose() {
    _controller.close();
  }
}

abstract class AuthEvent {}

class SessionExpiredEvent extends AuthEvent {}
