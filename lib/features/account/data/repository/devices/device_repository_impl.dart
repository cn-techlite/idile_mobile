import 'package:idile_mobile_app/features/account/data/model/devices/registered_device.dart';
import 'package:idile_mobile_app/features/account/data/service/devices/device_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/devices/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  const DeviceRepositoryImpl(this._remoteService);

  final DeviceRemoteService _remoteService;

  @override
  Future<List<RegisteredDevice>> devices() => _remoteService.devices();

  @override
  Future<RegisteredDevice> revokeDevice(String deviceId) =>
      _remoteService.revokeDevice(deviceId);
}
