import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/account/data/model/devices/registered_device.dart';

class DeviceRemoteService {
  const DeviceRemoteService(this._api);

  final ApiClient _api;

  Future<List<RegisteredDevice>> devices() => _api.get(
    Endpoints.devicesUrl,
    (value) => (value as List)
        .map(
          (item) =>
              RegisteredDevice.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
  );

  Future<RegisteredDevice> revokeDevice(String deviceId) {
    final id = deviceId.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        deviceId,
        'deviceId',
        'Device id cannot be empty.',
      );
    }
    return _api.delete(
      Endpoints.revokeDeviceUrl(id),
      (value) =>
          RegisteredDevice.fromJson(Map<String, dynamic>.from(value as Map)),
    );
  }
}
