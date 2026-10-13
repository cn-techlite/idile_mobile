import 'package:idile_mobile_app/features/account/data/model/devices/registered_device.dart';

abstract interface class DeviceRepository {
  Future<List<RegisteredDevice>> devices();

  Future<RegisteredDevice> revokeDevice(String deviceId);
}
