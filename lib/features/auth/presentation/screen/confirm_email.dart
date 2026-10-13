// ignore_for_file: use_build_context_synchronously

import 'package:idile_mobile_app/core/services/globals.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:idile_mobile_app/features/home/presentation/screen/home_screen.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/custom_snacker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pinput/pinput.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ConfirmEmailAddressScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final bool fromLogin;
  const ConfirmEmailAddressScreen({
    super.key,
    required this.email,
    required this.fromLogin,
    required this.password,
  });

  @override
  ConsumerState<ConfirmEmailAddressScreen> createState() =>
      _ConfirmEmailAddressScreenState();
}

class _ConfirmEmailAddressScreenState
    extends ConsumerState<ConfirmEmailAddressScreen>
    with WidgetsBindingObserver {
  final TextEditingController pinPutController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String pin = "";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); // <-- Add observer for lifecycle

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

  Future<void> resendCode() async {
    if (!globals.stopWatchTimer!.isRunning) {
      setState(() {
        globals.stopWatchTimer!.setPresetMinuteTime(1);
        globals.stopWatchTimer!.onStartTimer();
      });

      final result = await ref
          .read(authControllerProvider.notifier)
          .sendVerificationCode(email: widget.email);
      if (!mounted) return;
      if (result.isSuccess) {
        showSnack();
      } else {
        showCustomSnackbar(
          context,
          title: "Verification",
          content: result.message ?? "Failed to resend code",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack() {
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: AppText.raw("New code sent to your email")),
    );
  }

  void getPin(String value) {
    setState(() {
      pin = value;
    });
    ref.read(authControllerProvider.notifier).onOtpChanged(value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // <-- Always remove observer
    pinPutController.dispose();
    passwordController.dispose();
    globals.stopWatchTimer?.dispose();
    super.dispose();
  }

  // Listen to lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Optional: you can print or handle based on state
    if (kDebugMode) {
      print('Lifecycle state changed: $state');
    }

    // Example: pause the timer when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (globals.stopWatchTimer != null && globals.stopWatchTimer!.isRunning) {
        globals.stopWatchTimer!.onStopTimer();
      }
    }

    // Resume the timer when app returns
    if (state == AppLifecycleState.resumed) {
      if (globals.stopWatchTimer != null &&
          !globals.stopWatchTimer!.isRunning) {
        globals.stopWatchTimer!.onStartTimer();
      }
    }
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    if (pinPutController.text.trim().length < 5) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .verifyEmail(
          token: pinPutController.text.trim(),
          password: widget.password,
        );
    if (!mounted) return;
    if (result.isSuccess) {
      navigateAndRemoveUntilRoute(
        context,
        const HomeScreenPage(initialIndex: 0),
      );
    } else {
      showCustomSnackbar(
        context,
        title: "Verification",
        content: result.message ?? "Email verification failed",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;
    authAsync.value ?? const AuthState();

    final canVerify = pin.trim().length >= 5;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: theme.textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
    );
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 24.0,
              bottom: 24,
              left: 24,
              top: 100,
            ),
            child: Column(
              children: [
                AppText(
                  isBody: true,
                  text: "Verify your email address",
                  textAlign: TextAlign.start,
                  fontSize: 20,
                  color: colors.onSurface,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w800,
                ),
                addVerticalSpacing(1),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: colors.onSurfaceVariant),
                    children: [
                      TextSpan(
                        text:
                            "A verification code has been sent to your email ",
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          fontSize: 15.textSize,
                          fontFamily: "Inter",
                        ),
                      ),
                      TextSpan(
                        text: widget.fromLogin == false
                            ? widget.email
                            : widget.email,
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 15.textSize,
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                ),

                //addVerticalSpacing(1),
                addVerticalSpacing(7.5),
                Material(
                  color: Colors.transparent,
                  child: Pinput(
                    length: 5,
                    controller: pinPutController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration?.copyWith(
                        border: Border.all(color: colors.primary, width: 1.5),
                      ),
                    ),
                    onCompleted: (value) => submit(),
                    onChanged: getPin,
                  ),
                ),
                addVerticalSpacing(4),
                IgnorePointer(
                  ignoring: pin.isEmpty || pin.length < 5,
                  child: isLoading
                      ? SpinKitThreeBounce(color: colors.primary, size: 16)
                      : AppButton(
                          text: "VERIFY MAIL",
                          onPressed: (canVerify && !isLoading) ? submit : null,
                        ),
                ),

                addVerticalSpacing(6.25),
                StreamBuilder<int>(
                  stream: globals.stopWatchTimer!.rawTime,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data;
                    final displayTime = StopWatchTimer.getDisplayTime(
                      value!,
                      milliSecond: false,
                      minute: false,
                      hours: false,
                    );
                    return AppText.raw(
                      '$displayTime seconds',
                      style: TextStyle(
                        color: globals.stopWatchTimer!.isRunning
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
                addVerticalSpacing(5),
                AppButton(
                  text: 'Resend mail',
                  onPressed: globals.stopWatchTimer!.isRunning
                      ? null
                      : () => resendCode(),
                  variant: AppButtonVariant.text,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
