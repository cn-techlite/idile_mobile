import 'dart:async';

import 'package:idile_mobile_app/core/utils/package_export.dart';

enum ConnectivityStatus { notDetermined, isConnected, isDisconnected }

final connectivityStatusProviders =
    AsyncNotifierProvider<ConnectivityNotifier, ConnectivityStatus>(
      ConnectivityNotifier.new,
    );

class ConnectivityNotifier extends AsyncNotifier<ConnectivityStatus> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  FutureOr<ConnectivityStatus> build() async {
    // ✅ initial check
    final results = await Connectivity().checkConnectivity();

    final initialHasConnection = results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );

    // ✅ start listening
    _listenToConnectivity();

    ref.onDispose(() => _subscription?.cancel());

    return initialHasConnection
        ? ConnectivityStatus.isConnected
        : ConnectivityStatus.isDisconnected;
  }

  void _listenToConnectivity() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any(
        (r) =>
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet ||
            r == ConnectivityResult.vpn,
      );

      final newStatus = hasConnection
          ? ConnectivityStatus.isConnected
          : ConnectivityStatus.isDisconnected;

      if (state.value != newStatus) {
        state = AsyncData(newStatus);
      }
    });
  }
}
