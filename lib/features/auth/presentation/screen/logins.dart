// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/core/utils/package_export.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/forgot_password.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/user_register.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/device_approval.dart';
import 'package:idile_mobile_app/features/home/presentation/screen/home_screen.dart';
import 'package:idile_mobile_app/shared/providers/connectivity_state.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/custom_snacker.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';

class LoginScreens extends ConsumerStatefulWidget {
  const LoginScreens({super.key});

  @override
  ConsumerState<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends ConsumerState<LoginScreens> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    Future.microtask(() {
      ref.read(connectivityStatusProviders);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool rememberMe = false;
  void onChanged(bool? value) {
    setState(() {
      rememberMe = value ?? false;
    });
    ref.read(authControllerProvider.notifier).toggleRememberMe(rememberMe);
  }

  String isEmailChanged = "";
  String isPasswordChanged = "";

  void emailOnChanged(String value) {
    setState(() {
      isEmailChanged = value;
    });
    ref.read(authControllerProvider.notifier).onEmailChanged(value);
    printData("identifier", isEmailChanged);
  }

  void passwordOnChanged(String value) {
    setState(() {
      isPasswordChanged = value;
    });
    ref.read(authControllerProvider.notifier).onPasswordChanged(value);
    printData("identifier", isPasswordChanged);
  }

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;
    if (ref.read(connectivityStatusProviders).value !=
        ConnectivityStatus.isConnected) {
      return _showAuthError("Network Connection", "No Internet Connection");
    }
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          rememberMe: rememberMe,
        );
    if (!mounted) return;
    if (result.requiresDeviceApproval && result.deviceId != null) {
      return navigateToRoute(
        context,
        DeviceApprovalScreen(
          deviceId: result.deviceId!,
          onResend: () => ref
              .read(authControllerProvider.notifier)
              .login(
                email: emailController.text.trim(),
                password: passwordController.text,
                rememberMe: rememberMe,
              ),
        ),
      );
    }
    if (!result.isSuccess) {
      if (result.requiresTwoFactor) {
        return _showAuthError(
          "Two-factor authentication",
          result.message ?? "Enter your authentication code to continue.",
        );
      }
      return _showAuthError("Invalid User", result.message ?? "Login failed");
    }
    navigateAndReplaceRoute(context, const HomeScreenPage(initialIndex: 0));
  }

  Future<void> google() async {
    await _socialLogin(isApple: false);
  }

  Future<void> apple() async {
    await _socialLogin(isApple: true);
  }

  Future<void> _socialLogin({required bool isApple}) async {
    if (ref.read(connectivityStatusProviders).value !=
        ConnectivityStatus.isConnected) {
      return _showAuthError("Network Connection", "No Internet Connection");
    }
    final controller = ref.read(authControllerProvider.notifier);
    final result = isApple
        ? await controller.loginWithApple()
        : await controller.loginWithGoogle();
    if (!mounted) return;
    if (result.isCancelled) return;
    if (result.requiresDeviceApproval && result.deviceId != null) {
      return navigateToRoute(
        context,
        DeviceApprovalScreen(
          deviceId: result.deviceId!,
          onResend: isApple
              ? controller.loginWithApple
              : controller.loginWithGoogle,
        ),
      );
    }
    result.isSuccess
        ? navigateAndReplaceRoute(
            context,
            const HomeScreenPage(initialIndex: 0),
          )
        : _showAuthError(
            "Authentication",
            result.message ?? "Authentication failed",
          );
  }

  void _showAuthError(String title, String content) {
    showCustomSnackbar(
      context,
      title: title,
      content: content,
      type: SnackbarType.error,
      isTopPosition: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final canSubmit =
        isEmailChanged.trim().isNotEmpty && isPasswordChanged.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _BackgroundOrb(
              size: 230,
              color: colors.secondary.withValues(alpha: isDark ? .1 : .14),
            ),
          ),
          Positioned(
            top: 180,
            left: -95,
            child: _BackgroundOrb(
              size: 190,
              color: colors.onSurface.withValues(alpha: isDark ? .05 : .06),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 44,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: AutofillGroup(
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: AppLogo(markSize: 40, nameSize: 29),
                                ),
                                addVerticalSpacing(5.25),
                                AppText(
                                  text: 'Welcome home.',
                                  type: AppTextType.headlineLarge,
                                  color: colors.onSurface,
                                  fontFamily: 'Open Serif',
                                  fontSize: 38,
                                  height: 1.08,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                                addVerticalSpacing(1.25),
                                AppText(
                                  text: 'Sign in to keep your home, bills and subscriptions in one place.',
                                  type: AppTextType.bodyLarge,
                                  color: colors.onSurfaceVariant,
                                  fontSize: 16,
                                  height: 1.45,
                                ),
                                addVerticalSpacing(3.5),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: colors.outlineVariant,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? .22 : .05,
                                        ),
                                        blurRadius: 28,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const _FieldLabel(text: 'Email address'),
                                      addVerticalSpacing(1),
                                      GlobalTextField(
                                        fieldName: 'you@example.com',
                                        keyBoardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        borderRadius: 16,
                                        prefixIcon: const Icon(
                                          Icons.mail_outline_rounded,
                                          size: 20,
                                        ),
                                        textController: emailController,
                                        validator: (value) {
                                          final email = value?.trim() ?? '';
                                          if (email.isEmpty) {
                                            return 'Email is required';
                                          }
                                          if (!EmailValidator.validate(email)) {
                                            return 'Enter a valid email address';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          emailOnChanged(value ?? '');
                                        },
                                      ),
                                      addVerticalSpacing(2.5),
                                      const _FieldLabel(text: 'Password'),
                                      addVerticalSpacing(1),
                                      GlobalTextField(
                                        fieldName: 'Enter your password',
                                        obscureText: true,
                                        isEyeVisible: true,
                                        keyBoardType:
                                            TextInputType.visiblePassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        borderRadius: 16,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          size: 20,
                                        ),
                                        textController: passwordController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password is required';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          passwordOnChanged(value ?? '');
                                        },
                                        onFieldSubmitted: (_) {
                                          if (canSubmit && !isLoading) {
                                            loginUser();
                                          }
                                        },
                                      ),
                                      addVerticalSpacing(1),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: rememberMe,
                                              onChanged: onChanged,
                                              activeColor: colors.primary,
                                              checkColor: colors.onPrimary,
                                              side: BorderSide(
                                                color: colors.outline,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                          addHorizontalSpacing(2.25),
                                          Expanded(
                                            child: AppText(
                                              text: 'Remember me',
                                              type: AppTextType.bodyMedium,
                                              color: colors.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          AppButton(
                                            text: 'Forgot password?',
                                            onPressed: () => navigateToRoute(
                                              context,
                                              const ForgotPasswordScreen(),
                                            ),
                                            variant: AppButtonVariant.text,
                                            compact: true,
                                          ),
                                        ],
                                      ),
                                      addVerticalSpacing(1.75),
                                      AppButton(
                                        text: 'Sign in',
                                        onPressed: canSubmit ? loginUser : null,
                                        borderRadius: 16,
                                        heightPercent: 6.4,
                                        fontSize: 14,
                                        isLoading: isLoading,
                                      ),
                                      addVerticalSpacing(3),
                                      const _AuthDivider(),
                                      addVerticalSpacing(2.5),
                                      _SocialButton(
                                        label: 'Continue with Google',
                                        icon: SvgPicture.asset(
                                          'assets/svgs/google.svg',
                                          width: 22,
                                          height: 22,
                                        ),
                                        onPressed: isLoading ? null : google,
                                      ),
                                      if (defaultTargetPlatform ==
                                          TargetPlatform.iOS) ...[
                                        addVerticalSpacing(1.5),
                                        _SocialButton(
                                          label: 'Continue with Apple',
                                          icon: const Icon(
                                            Icons.apple,
                                            size: 25,
                                          ),
                                          onPressed: isLoading ? null : apple,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                addVerticalSpacing(3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppText(
                                      text: "New to Ìdílé?",
                                      type: AppTextType.bodyMedium,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    AppButton(
                                      text: 'Create an account',
                                      onPressed: () => navigateToRoute(
                                        context,
                                        const RegisterScreen(),
                                      ),
                                      variant: AppButtonVariant.text,
                                      compact: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      type: AppTextType.labelLarge,
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AppText(
            text: 'or continue with',
            type: AppTextType.bodySmall,
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(child: Divider(color: colors.outlineVariant)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = colors.onSurface;
    return AppButton(
      text: label,
      onPressed: onPressed,
      btnColor: colors.surface,
      textColor: foreground,
      borderColor: colors.outline,
      borderWidth: 1,
      borderRadius: 16,
      heightPercent: 6.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: foreground),
            child: icon,
          ),
          addHorizontalSpacing(3),
          AppText(
            text: label,
            type: AppTextType.labelLarge,
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
