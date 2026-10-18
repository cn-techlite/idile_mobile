import 'package:idile_mobile_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
