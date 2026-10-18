// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/core/utils/package_export.dart';
import 'package:idile_mobile_app/features/auth/domain/parameters/register_request.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/confirm_email.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/device_approval.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/screen/home_screen.dart';
import 'package:idile_mobile_app/shared/providers/connectivity_state.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/custom_snacker.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController email;
  late TextEditingController fistNameTEC;
  late TextEditingController lastNameTEC;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late TextEditingController phoneNo;

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    fistNameTEC = TextEditingController();
    lastNameTEC = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    phoneNo = TextEditingController();
  }

  @override
  void dispose() {
    email.dispose();
    fistNameTEC.dispose();
    lastNameTEC.dispose();
    password.dispose();
    confirmPassword.dispose();
    phoneNo.dispose();
    super.dispose();
  }

  RegisterRequest? userRegisterRequest;
  bool isChecked = false;
  Future<void> urlString(String? url) async {
    final link = Uri.parse(url!);
    if (await canLaunchUrl(link)) {
      await launchUrl(link);
    } else {
      throw 'Could not launch $url';
    }
  }

  void onChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
    ref.read(authControllerProvider.notifier).toggleTerms(isChecked);
  }

  String isEmailChanged = "";
  String isPasswordChanged = "";
  String isConfirmPasswordChanged = "";
  String isFirstNameChanged = "";
  String isLastNameChanged = "";
  String isPhoneNoChanged = "";

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

  void confirmPasswordOnChanged(String value) {
    setState(() {
      isConfirmPasswordChanged = value;
    });
    ref.read(authControllerProvider.notifier).onConfirmPasswordChanged(value);
    printData("identifier", isConfirmPasswordChanged);
  }

  void firstNameOnChanged(String value) {
    setState(() {
      isFirstNameChanged = value;
    });
    ref.read(authControllerProvider.notifier).onFirstNameChanged(value);
    printData("identifier", isFirstNameChanged);
  }

  void lastNameOnChanged(String value) {
    setState(() {
      isLastNameChanged = value;
    });
    ref.read(authControllerProvider.notifier).onLastNameChanged(value);
    printData("identifier", isLastNameChanged);
  }

  void phoneNoChanged(String value) {
    setState(() {
      isPhoneNoChanged = value;
    });
    ref.read(authControllerProvider.notifier).onPhoneChanged(value);
    printData("identifier", isPhoneNoChanged);
  }

  Future<void> userRegister() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (connectivityStatusProvider.value == ConnectivityStatus.isConnected) {
        if (isChecked == true) {
          userRegisterRequest = RegisterRequest(
            email: email.text.trim(),
            name: '${fistNameTEC.text.trim()} ${lastNameTEC.text.trim()}'
                .trim(),
            password: password.text.trim(),
            phoneNo: isPhoneNoChanged,
          );
          final result = await ref
              .read(authControllerProvider.notifier)
              .register(request: userRegisterRequest!);
          if (!mounted) return;
          if (result.isSuccess) {
            navigateToRoute(
              context,
              ConfirmEmailAddressScreen(
                email: email.text.trim(),
                fromLogin: false,
                password: password.text.trim(),
              ),
            );
          } else {
            showCustomSnackbar(
              context,
              title: "User Exist",
              content: result.message ?? "Registration failed",
              type: SnackbarType.error,
              isTopPosition: false,
            );
          }
        } else {
          showCustomSnackbar(
            context,
            title: "Terms of Service",
            content: "Please accept terms & condition",
            type: SnackbarType.error,
            isTopPosition: false,
          );
        }
      } else {
        showCustomSnackbar(
          context,
          title: "Network Connection",
          content: "No Internet Connection",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }
    }
  }

  Future<void> google() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);

    if (connectivityStatusProvider.value == ConnectivityStatus.isConnected) {
      if (isChecked == true) {
        final result = await ref
            .read(authControllerProvider.notifier)
            .loginWithGoogle();
        if (!mounted) return;
        if (result.isCancelled) return;
        if (result.requiresDeviceApproval && result.deviceId != null) {
          return navigateToRoute(
            context,
            DeviceApprovalScreen(
              deviceId: result.deviceId!,
              onResend: ref
                  .read(authControllerProvider.notifier)
                  .loginWithGoogle,
            ),
          );
        }
        if (result.isSuccess) {
          navigateAndReplaceRoute(
            context,
            const HomeScreenPage(initialIndex: 0),
          );
        } else {
          showCustomSnackbar(
            context,
            title: "Authentication",
            content: result.message ?? "Authentication failed",
            type: SnackbarType.error,
            isTopPosition: false,
          );
        }
      } else {
        showCustomSnackbar(
          context,
          title: "Terms of Service",
          content: "Please accept terms & condition",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }
    } else {
      showCustomSnackbar(
        context,
        title: "Network Connection",
        content: "No Internet Connection",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> apple() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);

    if (connectivityStatusProvider.value == ConnectivityStatus.isConnected) {
      if (isChecked == true) {
        final result = await ref
            .read(authControllerProvider.notifier)
            .loginWithApple();
        if (!mounted) return;
        if (result.isCancelled) return;
        if (result.requiresDeviceApproval && result.deviceId != null) {
          return navigateToRoute(
            context,
            DeviceApprovalScreen(
              deviceId: result.deviceId!,
              onResend: ref
                  .read(authControllerProvider.notifier)
                  .loginWithApple,
            ),
          );
        }
        if (result.isSuccess) {
          navigateAndReplaceRoute(
            context,
            const HomeScreenPage(initialIndex: 0),
          );
        } else {
          showCustomSnackbar(
            context,
            title: "Authentication",
            content: result.message ?? "Authentication failed",
            type: SnackbarType.error,
            isTopPosition: false,
          );
        }
      } else {
        showCustomSnackbar(
          context,
          title: "Terms of Service",
          content: "Please accept terms & condition",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }
    } else {
      showCustomSnackbar(
        context,
        title: "Network Connection",
        content: "No Internet Connection",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final canSubmit =
        isFirstNameChanged.trim().isNotEmpty &&
        isLastNameChanged.trim().isNotEmpty &&
        isEmailChanged.trim().isNotEmpty &&
        isPhoneNoChanged.trim().isNotEmpty &&
        isPasswordChanged.isNotEmpty &&
        isConfirmPasswordChanged.isNotEmpty &&
        isChecked;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _RegisterBackgroundOrb(
              size: 230,
              color: colors.secondary.withValues(alpha: isDark ? .1 : .14),
            ),
          ),
          Positioned(
            top: 230,
            left: -95,
            child: _RegisterBackgroundOrb(
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
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: AutofillGroup(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Back',
                                    onPressed: () =>
                                        Navigator.maybePop(context),
                                    icon: Icon(
                                      Icons.arrow_back_rounded,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  addHorizontalSpacing(1),
                                  const AppLogo(markSize: 36, nameSize: 27),
                                ],
                              ),
                              addVerticalSpacing(4.25),
                              AppText(
                                text: 'Create your account.',
                                type: AppTextType.headlineLarge,
                                color: colors.onSurface,
                                fontFamily: 'Open Serif',
                                fontSize: 36,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                              addVerticalSpacing(1.25),
                              AppText(
                                text: 'Bring your home, bills and subscriptions together in one calm place.',
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
                                    const _RegisterFieldLabel(
                                      text: 'First name',
                                    ),
                                    addVerticalSpacing(1),
                                    GlobalTextField(
                                      fieldName: 'Your first name',
                                      keyBoardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.givenName,
                                      ],
                                      borderRadius: 16,
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                        size: 20,
                                      ),
                                      textController: fistNameTEC,
                                      validator: (value) =>
                                          (value?.trim().isEmpty ?? true)
                                          ? 'First name is required'
                                          : null,
                                      onChanged: (value) {
                                        firstNameOnChanged(value ?? '');
                                      },
                                    ),
                                    addVerticalSpacing(2.25),
                                    const _RegisterFieldLabel(
                                      text: 'Last name',
                                    ),
                                    addVerticalSpacing(1),
                                    GlobalTextField(
                                      fieldName: 'Your last name',
                                      keyBoardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.familyName,
                                      ],
                                      borderRadius: 16,
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                        size: 20,
                                      ),
                                      textController: lastNameTEC,
                                      validator: (value) =>
                                          (value?.trim().isEmpty ?? true)
                                          ? 'Last name is required'
                                          : null,
                                      onChanged: (value) {
                                        lastNameOnChanged(value ?? '');
                                      },
                                    ),
                                    addVerticalSpacing(2.25),
                                    const _RegisterFieldLabel(
                                      text: 'Email address',
                                    ),
                                    addVerticalSpacing(1),
                                    GlobalTextField(
                                      fieldName: 'you@example.com',
                                      keyBoardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      borderRadius: 16,
                                      prefixIcon: const Icon(
                                        Icons.mail_outline_rounded,
                                        size: 20,
                                      ),
                                      textController: email,
                                      validator: (value) {
                                        final text = value?.trim() ?? '';
                                        if (text.isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!EmailValidator.validate(text)) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        emailOnChanged(value ?? '');
                                      },
                                    ),
                                    addVerticalSpacing(2.25),
                                    const _RegisterFieldLabel(
                                      text: 'Phone number',
                                    ),
                                    addVerticalSpacing(1),
                                    GlobalPhoneTextField(
                                      fieldName: 'Phone number',
                                      textController: phoneNo,
                                      borderRadius: 16,
                                      onChanged: (value) {
                                        phoneNoChanged(
                                          value?.completeNumber ?? '',
                                        );
                                      },
                                    ),
                                    addVerticalSpacing(2.25),
                                    const _RegisterFieldLabel(text: 'Password'),
                                    addVerticalSpacing(1),
                                    GlobalTextField(
                                      fieldName: 'At least 8 characters',
                                      obscureText: true,
                                      isEyeVisible: true,
                                      keyBoardType:
                                          TextInputType.visiblePassword,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.newPassword,
                                      ],
                                      borderRadius: 16,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 20,
                                      ),
                                      textController: password,
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
                                    ),
                                    addVerticalSpacing(2.25),
                                    const _RegisterFieldLabel(
                                      text: 'Confirm password',
                                    ),
                                    addVerticalSpacing(1),
                                    GlobalTextField(
                                      fieldName: 'Repeat your password',
                                      obscureText: true,
                                      isEyeVisible: true,
                                      keyBoardType:
                                          TextInputType.visiblePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.newPassword,
                                      ],
                                      borderRadius: 16,
                                      prefixIcon: const Icon(
                                        Icons.lock_reset_rounded,
                                        size: 20,
                                      ),
                                      textController: confirmPassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value != password.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        confirmPasswordOnChanged(value ?? '');
                                      },
                                      onFieldSubmitted: (_) {
                                        if (canSubmit && !isLoading) {
                                          userRegister();
                                        }
                                      },
                                    ),
                                    addVerticalSpacing(2.25),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: isChecked,
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
                                        addHorizontalSpacing(2.5),
                                        Expanded(
                                          child: _RegisterTermsCopy(
                                            openUrl: urlString,
                                          ),
                                        ),
                                      ],
                                    ),
                                    addVerticalSpacing(2.75),
                                    AppButton(
                                      text: 'Create account',
                                      onPressed: canSubmit
                                          ? userRegister
                                          : null,
                                      borderRadius: 16,
                                      heightPercent: 6.4,
                                      fontSize: 14,
                                      isLoading: isLoading,
                                    ),
                                    addVerticalSpacing(3),
                                    const _RegisterAuthDivider(),
                                    addVerticalSpacing(2.5),
                                    _RegisterSocialButton(
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
                                      _RegisterSocialButton(
                                        label: 'Continue with Apple',
                                        icon: const Icon(Icons.apple, size: 25),
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
                                    text: 'Already have an account?',
                                    type: AppTextType.bodyMedium,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  AppButton(
                                    text: 'Sign in',
                                    onPressed: () => navigateToRoute(
                                      context,
                                      const LoginScreens(),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterBackgroundOrb extends StatelessWidget {
  const _RegisterBackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

class _RegisterFieldLabel extends StatelessWidget {
  const _RegisterFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => AppText(
    text: text,
    type: AppTextType.labelLarge,
    color: Theme.of(context).colorScheme.onSurface,
    fontWeight: FontWeight.w700,
  );
}

class _RegisterTermsCopy extends StatelessWidget {
  const _RegisterTermsCopy({required this.openUrl});

  final Future<void> Function(String? url) openUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppText(
          text: 'I agree to the ',
          type: AppTextType.bodySmall,
          color: colors.onSurfaceVariant,
          height: 1.45,
        ),
        GestureDetector(
          onTap: () => openUrl('https://idile.com.ng/terms-of-use/'),
          child: AppText(
            text: 'Terms & Conditions',
            type: AppTextType.bodySmall,
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
        AppText(
          text: ' and ',
          type: AppTextType.bodySmall,
          color: colors.onSurfaceVariant,
        ),
        GestureDetector(
          onTap: () => openUrl('https://idile.com.ng/privacy-policy/'),
          child: AppText(
            text: 'Privacy Policy',
            type: AppTextType.bodySmall,
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

class _RegisterAuthDivider extends StatelessWidget {
  const _RegisterAuthDivider();

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

class _RegisterSocialButton extends StatelessWidget {
  const _RegisterSocialButton({
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
