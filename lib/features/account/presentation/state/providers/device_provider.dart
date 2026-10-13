import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/repository/devices/device_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/service/devices/device_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/controller/devices/device_controller.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/devices/device_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/device_state.dart';

final deviceRemoteServiceProvider = Provider<DeviceRemoteService>(
  (ref) => DeviceRemoteService(ref.read(apiClientProvider)),
);

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepositoryImpl(ref.read(deviceRemoteServiceProvider)),
);

final deviceControllerProvider =
    AsyncNotifierProvider<DeviceController, DeviceState>(DeviceController.new);
