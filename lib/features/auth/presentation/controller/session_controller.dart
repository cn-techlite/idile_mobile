import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';

class SessionController extends AsyncNotifier<UserProfile?> {
  @override
  FutureOr<UserProfile?> build() =>
      ref.read(sessionUseCasesProvider).restoreSession();

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(sessionUseCasesProvider)
          .login(
            email: email.trim(),
            password: password,
            rememberMe: rememberMe,
          ),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(sessionUseCasesProvider)
          .register(name: name.trim(), email: email.trim(), password: password),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(sessionUseCasesProvider).logout();
    } finally {
      state = const AsyncData(null);
    }
  }
}
