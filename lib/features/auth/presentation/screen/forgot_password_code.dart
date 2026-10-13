// ignore_for_file: use_build_context_synchronously

import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/services/globals.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/core/utils/package_export.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/back_icon.dart';
import 'package:idile_mobile_app/shared/widgets/custom_snacker.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

class ForgotPasswordCodeScreen extends ConsumerStatefulWidget {
  const ForgotPasswordCodeScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<ForgotPasswordCodeScreen> createState() =>
      _ForgotPasswordCodeScreenState();
}

class _ForgotPasswordCodeScreenState
    extends ConsumerState<ForgotPasswordCodeScreen> {
  late TextEditingController codeController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  late FocusNode codeFocusNode = FocusNode();
  late FocusNode newPasswordFocusNode = FocusNode();
  late FocusNode confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool saveButtonPressed = false;
  String isOTPChanged = "";
  String isNewPasswordChanged = "";
  String isConfirmPasswordChanged = "";

  void otpOnChanged(String value) {
    setState(() {
      isOTPChanged = value;
    });
    ref.read(authControllerProvider.notifier).onOtpChanged(value);
    printData("identifier", isOTPChanged);
  }

  void newPasswordOnChanged(String value) {
    setState(() {
      isNewPasswordChanged = value;
    });
    ref.read(authControllerProvider.notifier).onPasswordChanged(value);
    printData("identifier", isNewPasswordChanged);
  }

  void confirmPasswordOnChanged(String value) {
    setState(() {
      isConfirmPasswordChanged = value;
    });
    ref.read(authControllerProvider.notifier).onConfirmPasswordChanged(value);
    printData("identifier", isConfirmPasswordChanged);
  }

  Future<void> onSubmit() async {
    setState(() {
      saveButtonPressed = true;
    });
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final controller = ref.read(authControllerProvider.notifier);
      final verification = await controller.verifyPasswordResetCode(
        email: widget.email,
        code: codeController.text.trim(),
      );
      if (!mounted) return;
      if (!verification.isSuccess) {
        return showCustomSnackbar(
          context,
          title: "Invalid Code",
          content: verification.message ?? "Unable to verify reset code",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }

      final resetToken = verification.rawData?.toString() ?? '';
      final result = await controller.resetPassword(
        resetToken: resetToken,
        password: newPasswordController.text.trim(),
      );
      if (!mounted) return;
      if (result.isSuccess) {
        navigateToRoute(context, const LoginScreens());
      } else {
        showCustomSnackbar(
          context,
          title: "User Error",
          content: result.message ?? "Unable to reset password",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }
    }
  }

  bool obscureText = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    codeController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    globals.stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      onEnded: () {
        setState(() {});
      },
    );
    globals.stopWatchTimer!.setPresetMinuteTime(1);
    globals.stopWatchTimer!.onStartTimer();
    super.initState();
  }

  @override
  void dispose() {
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> resendCode() async {
    if (!globals.stopWatchTimer!.isRunning) {
      setState(() {
        globals.stopWatchTimer!.setPresetMinuteTime(1);
        globals.stopWatchTimer!.onStartTimer();
      });

      final result = await ref
          .read(authControllerProvider.notifier)
          .resendPasswordCode(email: widget.email);
      if (!mounted) return;
      if (result.isSuccess) showSnack();
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack() {
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: AppText.raw("New code sent to your email")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canSubmit =
        isOTPChanged.trim().isNotEmpty &&
        isNewPasswordChanged.isNotEmpty &&
        isConfirmPasswordChanged.isNotEmpty &&
        isConfirmPasswordChanged == isNewPasswordChanged;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: buildFlexibleAppBar(context: context),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppText(
                  isBody: false,
                  text: "Create New Password",
                  textAlign: TextAlign.start,
                  fontSize: 18,
                  color: colors.onSurface,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                ),
                addVerticalSpacing(1.25),
                AppText(
                  isBody: true,
                  text:
                      "Enter the 6-digit code sent to ${widget.email}, then choose a new password.",
                  textAlign: TextAlign.start,
                  fontSize: 15,
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                ),
                addVerticalSpacing(2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.raw(
                      "OTP Code",
                      style: TextStyle(
                        fontSize: 12.textSize,
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Mulish",
                      ),
                    ),
                    GlobalTextField(
                      fieldName: '6-digit code',
                      keyBoardType: TextInputType.number,
                      obscureText: false,
                      maxLength: 6,
                      textController: codeController,
                      validator: (value) => value?.trim().length == 6
                          ? null
                          : 'Enter the 6-digit code',
                      onChanged: (String? value) {
                        otpOnChanged(value!);
                      },
                    ),
                  ],
                ),
                addVerticalSpacing(4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isBody: false,
                      text: "New Password",
                      textAlign: TextAlign.start,
                      fontSize: 12,
                      color: colors.onSurface,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                    ),
                    GlobalTextField(
                      fieldName: 'New Password',
                      keyBoardType: TextInputType.visiblePassword,
                      obscureText: true,
                      isEyeVisible: true,
                      textController: newPasswordController,
                      onChanged: (String? value) {
                        newPasswordOnChanged(value!);
                      },
                    ),
                  ],
                ),
                addVerticalSpacing(4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isBody: false,
                      text: "Confirm Password",
                      textAlign: TextAlign.start,
                      fontSize: 12,
                      color: colors.onSurface,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                    ),
                    GlobalTextField(
                      fieldName: 'Confirm Password',
                      keyBoardType: TextInputType.visiblePassword,
                      obscureText: true,
                      isEyeVisible: true,
                      confirmPasswordMatch: newPasswordController.text,
                      textController: confirmPasswordController,
                      onChanged: (String? value) {
                        confirmPasswordOnChanged(value!);
                      },
                    ),
                  ],
                ),
                addVerticalSpacing(5),
                AppButton(
                  text: "Update Password",
                  onPressed: canSubmit ? onSubmit : null,
                  isLoading: isLoading,
                ),
                addVerticalSpacing(5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
