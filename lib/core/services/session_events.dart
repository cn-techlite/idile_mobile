import 'dart:async';

class SessionEvents {
  const SessionEvents._();

  static final _deviceRevokedController = StreamController<void>.broadcast();

  static Stream<void> get deviceRevoked => _deviceRevokedController.stream;

  static void notifyDeviceRevoked() => _deviceRevokedController.add(null);
}
