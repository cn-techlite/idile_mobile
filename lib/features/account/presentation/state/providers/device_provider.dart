import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/controller/devices/device_controller.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/device_state.dart';

final deviceControllerProvider =
    AsyncNotifierProvider<DeviceController, DeviceState>(DeviceController.new);
