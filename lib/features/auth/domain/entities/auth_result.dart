import 'package:idile_mobile_app/features/auth/domain/entities/login_response.dart';

class AuthResultModel {
  const AuthResultModel({
    required this.isSuccess,
    this.message,
    this.loginData,
    this.rawData,
    this.requiresTwoFactor = false,
    this.requiresDeviceApproval = false,
    this.deviceId,
    this.isCancelled = false,
  });

  final bool isSuccess;
  final String? message;
  final LoginResponseModel? loginData;
  final dynamic rawData;
  final bool requiresTwoFactor;
  final bool requiresDeviceApproval;
  final String? deviceId;
  final bool isCancelled;

  factory AuthResultModel.success({
    LoginResponseModel? loginData,
    dynamic rawData,
    String? message,
  }) {
    return AuthResultModel(
      isSuccess: true,
      loginData: loginData,
      rawData: rawData,
      message: message,
    );
  }

  factory AuthResultModel.failure(String message) {
    return AuthResultModel(isSuccess: false, message: message);
  }

  factory AuthResultModel.cancelled() =>
      const AuthResultModel(isSuccess: false, isCancelled: true);

  factory AuthResultModel.twoFactorRequired({
    required dynamic challenge,
    String? message,
  }) => AuthResultModel(
    isSuccess: false,
    requiresTwoFactor: true,
    rawData: challenge,
    message: message ?? 'Two-factor verification is required.',
  );

  factory AuthResultModel.deviceApprovalRequired({required String deviceId}) =>
      AuthResultModel(
        isSuccess: false,
        requiresDeviceApproval: true,
        deviceId: deviceId,
        message: 'Enter the 6-digit code sent to your email.',
      );
}
