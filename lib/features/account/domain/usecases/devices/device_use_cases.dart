import 'package:idile_mobile_app/features/account/domain/entities/devices/registered_device.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/devices/device_repository.dart';

final class DeviceUseCases {
  const DeviceUseCases(this._repository);

  final DeviceRepository _repository;

  Future<List<RegisteredDevice>> devices() => _repository.devices();

  Future<RegisteredDevice> revokeDevice(String deviceId) =>
      _repository.revokeDevice(deviceId);
}
