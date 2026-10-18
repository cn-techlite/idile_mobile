import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/features/auth/presentation/controller/session_controller.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, UserProfile?>(
      SessionController.new,
    );
