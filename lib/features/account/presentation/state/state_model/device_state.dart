import 'package:idile_mobile_app/features/account/data/model/devices/registered_device.dart';

class DeviceState {
  const DeviceState({
    this.devices = const [],
    this.isRefreshing = false,
    this.revokingDeviceIds = const {},
  });

  final List<RegisteredDevice> devices;
  final bool isRefreshing;
  final Set<String> revokingDeviceIds;

  bool isRevoking(String deviceId) => revokingDeviceIds.contains(deviceId);

  DeviceState setRevoking(String deviceId, bool loading) {
    final ids = {...revokingDeviceIds};
    if (loading) {
      ids.add(deviceId);
    } else {
      ids.remove(deviceId);
    }
    return copyWith(revokingDeviceIds: Set.unmodifiable(ids));
  }

  DeviceState replaceDevice(RegisteredDevice updated) => copyWith(
    devices: [
      for (final device in devices)
        if (device.id == updated.id) updated else device,
    ],
    revokingDeviceIds: Set.unmodifiable(
      revokingDeviceIds.where((id) => id != updated.id),
    ),
  );

  DeviceState copyWith({
    List<RegisteredDevice>? devices,
    bool? isRefreshing,
    Set<String>? revokingDeviceIds,
  }) => DeviceState(
    devices: devices ?? this.devices,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    revokingDeviceIds: revokingDeviceIds ?? this.revokingDeviceIds,
  );
}
