import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/devices/device_use_cases.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/device_state.dart';

class DeviceController extends AsyncNotifier<DeviceState> {
  DeviceUseCases get _useCases => ref.read(deviceUseCasesProvider);

  @override
  FutureOr<DeviceState> build() => _load();

  Future<DeviceState> _load() async =>
      DeviceState(devices: await _useCases.devices());

  Future<void> refreshDevices() async {
    final current = state.value;
    if (current == null) {
      state = const AsyncLoading();
      state = await AsyncValue.guard(_load);
      return;
    }
    state = AsyncData(current.copyWith(isRefreshing: true));
    try {
      state = AsyncData(DeviceState(devices: await _useCases.devices()));
    } catch (error) {
      state = AsyncData(current.copyWith(isRefreshing: false));
      rethrow;
    }
  }

  Future<void> revokeDevice(String deviceId) async {
    final current = state.value;
    if (current == null || current.isRevoking(deviceId)) return;
    final device = current.devices
        .where((item) => item.id == deviceId)
        .firstOrNull;
    if (device == null || !device.canRevoke) return;

    state = AsyncData(current.setRevoking(deviceId, true));
    try {
      final response = await _useCases.revokeDevice(deviceId);
      final revoked = response.copyWith(
        status: 'revoked',
        revokedAt: response.revokedAt ?? DateTime.now().toUtc(),
      );
      final latest = state.value ?? current;
      state = AsyncData(latest.replaceDevice(revoked));
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(latest.setRevoking(deviceId, false));
      rethrow;
    }
  }
}
