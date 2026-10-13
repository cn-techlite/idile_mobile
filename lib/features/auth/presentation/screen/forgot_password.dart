// ignore_for_file: use_build_context_synchronously

import 'package:idile_mobile_app/core/constants/constants.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/forgot_password_code.dart';
import 'package:idile_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/back_icon.dart';
import 'package:idile_mobile_app/shared/widgets/custom_snacker.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late TextEditingController emailController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool saveButtonPressed = false;
  String isEmailChanged = "";

  void emailOnChanged(String value) {
    setState(() {
      isEmailChanged = value;
    });
    ref.read(authControllerProvider.notifier).onEmailChanged(value);
    printData("identifier", isEmailChanged);
  }

  Future<void> onSubmit() async {
    setState(() {
      saveButtonPressed = true;
    });
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final result = await ref
          .read(authControllerProvider.notifier)
          .resendPasswordCode(email: emailController.text.trim());
      if (!mounted) return;
      if (result.isSuccess) {
        navigateToRoute(
          context,
          ForgotPasswordCodeScreen(email: emailController.text.trim()),
        );
      } else {
        showCustomSnackbar(
          context,
          title: "Password Reset",
          content: result.message ?? "Unable to send reset code",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }
    }
  }

  @override
  void initState() {
    emailController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: buildFlexibleAppBar(context: context),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isBody: false,
                      text: "Forgot Password",
                      textAlign: TextAlign.center,
                      fontSize: 18,
                      color: colors.onSurface,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                    ),
                    AppText(
                      isBody: true,
                      text: "Enter your email address",
                      textAlign: TextAlign.start,
                      fontSize: 18,
                      color: colors.onSurfaceVariant,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                    ),
                    addVerticalSpacing(5),
                    AppText(
                      isBody: false,
                      text: "Email Address",
                      textAlign: TextAlign.start,
                      fontSize: 12,
                      color: colors.onSurface,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                    ),
                    GlobalTextField(
                      fieldName: 'Email',
                      keyBoardType: TextInputType.emailAddress,
                      obscureText: false,
                      textController: emailController,
                      onChanged: (String? value) {
                        emailOnChanged(value!);
                      },
                    ),
                    addVerticalSpacing(4),
                    AppButton(
                      text: "Send code",
                      onPressed: isEmailChanged.trim().isNotEmpty
                          ? onSubmit
                          : null,
                      isLoading: isLoading,
                    ),
                    addVerticalSpacing(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          isBody: true,
                          text: "Remember password? Back to  ",
                          textAlign: TextAlign.center,
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w500,
                        ),
                        GestureDetector(
                          onTap: () {
                            navigateToRoute(context, const LoginScreens());
                          },
                          child: AppText(
                            isBody: false,
                            text: "Sign In",
                            textAlign: TextAlign.center,
                            fontSize: 15,
                            color: colors.primary,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
