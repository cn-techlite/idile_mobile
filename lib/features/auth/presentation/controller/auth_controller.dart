import 'dart:async';

import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/features/auth/domain/entities/auth_result.dart';
import 'package:idile_mobile_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:idile_mobile_app/features/auth/domain/parameters/register_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/update_profile_request.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/wallet_request.dart';

class AuthController extends AsyncNotifier<AuthState> {
  late final AuthUseCases _useCases;

  @override
  FutureOr<AuthState> build() async {
    _useCases = ref.read(authUseCasesProvider);
    return const AuthState();
  }

  AuthState get _current => state.value ?? const AuthState();

  void toggleRememberMe(bool value) {
    state = AsyncData(_current.copyWith(rememberMe: value));
  }

  void toggleTerms(bool value) {
    state = AsyncData(_current.copyWith(agreedToTerms: value));
  }

  void selectEmail() {
    state = AsyncData(
      _current.copyWith(
        isEmailSelected: true,
        isPhoneSelected: false,
        email: '',
        phone: '',
      ),
    );
  }

  void selectPhone() {
    state = AsyncData(
      _current.copyWith(
        isEmailSelected: false,
        isPhoneSelected: true,
        email: '',
        phone: '',
      ),
    );
  }

  void onEmailChanged(String value) {
    state = AsyncData(_current.copyWith(email: value));
  }

  void onPasswordChanged(String value) {
    state = AsyncData(_current.copyWith(password: value));
  }

  void onPhoneChanged(String value) {
    state = AsyncData(_current.copyWith(phone: value));
  }

  void onCountryCodeChanged(String value) {
    state = AsyncData(_current.copyWith(countryCode: value));
  }

  void onFirstNameChanged(String value) {
    state = AsyncData(_current.copyWith(firstName: value));
  }

  void onLastNameChanged(String value) {
    state = AsyncData(_current.copyWith(lastName: value));
  }

  void onConfirmPasswordChanged(String value) {
    state = AsyncData(_current.copyWith(confirmPassword: value));
  }

  void onOtpChanged(String value) {
    state = AsyncData(_current.copyWith(otp: value));
  }

  void onSexChanged(String value) =>
      state = AsyncData(_current.copyWith(sex: value));
  void onAddressChanged(String value) =>
      state = AsyncData(_current.copyWith(address: value));
  void onDateOfBirthChanged(String value) =>
      state = AsyncData(_current.copyWith(dateOfBirth: value));
  void onNationalityChanged(String value) =>
      state = AsyncData(_current.copyWith(nationality: value));
  void onStateLocationChanged(String value) =>
      state = AsyncData(_current.copyWith(stateLocation: value));
  void onNextOfKinChanged(String value) =>
      state = AsyncData(_current.copyWith(nextOfKin: value));
  void onPinCodeChanged(String value) =>
      state = AsyncData(_current.copyWith(pinCode: value));
  void onWalletNameChanged(String value) =>
      state = AsyncData(_current.copyWith(walletName: value));
  void onBvnChanged(String value) =>
      state = AsyncData(_current.copyWith(bvn: value));
  void onBvnDateOfBirthChanged(String value) =>
      state = AsyncData(_current.copyWith(bvnDateOfBirth: value));

  Future<AuthResultModel> updateProfile(UpdateProfileRequest request) =>
      _runAction(() => _useCases.updateProfile(request: request));

  Future<AuthResultModel> createWallet(WalletRequest request) =>
      _runAction(() => _useCases.createWallet(request: request));

  Future<AuthResultModel> _runAction(
    Future<AuthResultModel> Function() action,
  ) async {
    final previous = _current;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(isSuccess: false, message: 'Request failed');
  }

  Future<AuthResultModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _useCases.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Login failed");
  }

  Future<AuthResultModel> register({required RegisterRequest request}) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _useCases.register(request: request);
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Registration failed");
  }

  Future<AuthResultModel> loginWithGoogle() async {
    final previous = _current;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await _useCases.signInWithGoogle();
    });
    state = AsyncData(previous);
    printData("google Login", result.value?.message);

    return result.value ??
        const AuthResultModel(
          isSuccess: false,
          message: "Google sign-in failed",
        );
  }

  Future<AuthResultModel> loginWithApple() async {
    final previous = _current;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await _useCases.signInWithApple();
    });
    state = AsyncData(previous);

    printData("Apple Login", result.value?.message);

    return result.value ??
        const AuthResultModel(
          isSuccess: false,
          message: "Apple sign-in failed",
        );
  }

  Future<AuthResultModel> approveDevice({
    required String deviceId,
    required String code,
  }) =>
      _runAction(() => _useCases.approveDevice(deviceId: deviceId, code: code));

  Future<AuthResultModel> reportUnrecognisedDevice(String token) =>
      _runAction(() => _useCases.reportUnrecognisedDevice(token));

  Future<AuthResultModel> verifyEmail({
    required String token,
    required String password,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _useCases.verifyEmail(token: token, password: password);
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Verification failed");
  }

  Future<AuthResultModel> sendVerificationCode({required String email}) async {
    return await _useCases.sendVerificationCode(email: email);
  }

  Future<AuthResultModel> resendPasswordCode({required String email}) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _useCases.resendPasswordCode(email: email);
    });

    state = AsyncData(previous);

    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Failed to send OTP");
  }

  Future<AuthResultModel> verifyPasswordResetCode({
    required String email,
    required String code,
  }) => _runAction(
    () => _useCases.verifyPasswordResetCode(email: email, code: code),
  );

  Future<AuthResultModel> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _useCases.resetPassword(
        resetToken: resetToken,
        password: password,
      );
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(
          isSuccess: false,
          message: "Password reset failed",
        );
  }

  Future<AuthResultModel> logout() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _useCases.logout();
    });

    state = AsyncData(const AuthState());

    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Logout failed");
  }
}
