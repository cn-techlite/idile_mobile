import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/features/auth/data/model/auth_result_model.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/screen/home_screen.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/custom_snacker.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

typedef ResendDeviceApproval = Future<AuthResultModel> Function();

class DeviceApprovalScreen extends ConsumerStatefulWidget {
  const DeviceApprovalScreen({
    super.key,
    required this.deviceId,
    required this.onResend,
  });

  final String deviceId;
  final ResendDeviceApproval onResend;

  @override
  ConsumerState<DeviceApprovalScreen> createState() =>
      _DeviceApprovalScreenState();
}

class _DeviceApprovalScreenState extends ConsumerState<DeviceApprovalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  late String _deviceId = widget.deviceId;
  bool _resending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(authControllerProvider.notifier)
        .approveDevice(deviceId: _deviceId, code: _codeController.text.trim());
    if (!mounted) return;
    if (result.isSuccess) {
      navigateAndRemoveUntilRoute(
        context,
        const HomeScreenPage(initialIndex: 0),
      );
      return;
    }
    _showError(result.message ?? 'The approval code could not be verified.');
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    final result = await widget.onResend();
    if (!mounted) return;
    setState(() {
      _resending = false;
      if (result.deviceId != null && result.deviceId!.isNotEmpty) {
        _deviceId = result.deviceId!;
      }
    });
    if (result.requiresDeviceApproval) {
      showCustomSnackbar(
        context,
        title: 'Code sent',
        content: 'A new 6-digit approval code was sent to your email.',
        type: SnackbarType.success,
        isTopPosition: false,
      );
    } else if (result.isSuccess) {
      navigateAndRemoveUntilRoute(
        context,
        const HomeScreenPage(initialIndex: 0),
      );
    } else if (!result.isCancelled) {
      _showError(result.message ?? 'A new code could not be sent.');
    }
  }

  void _showError(String message) {
    showCustomSnackbar(
      context,
      title: 'Device approval',
      content: message,
      type: SnackbarType.error,
      isTopPosition: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(markSize: 44, nameSize: 32)),
                addVerticalSpacing(4.75),
                AppText(
                  text: 'Approve this device',
                  type: AppTextType.headlineMedium,
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
                addVerticalSpacing(1.5),
                AppText(
                  text: 'For your security, enter the 6-digit code sent to your email. The code is valid for 10 minutes.',
                  type: AppTextType.bodyMedium,
                  color: colors.onSurfaceVariant,
                  textAlign: TextAlign.center,
                  height: 1.5,
                ),
                addVerticalSpacing(4),
                GlobalTextField(
                  fieldName: '6-digit code',
                  keyBoardType: TextInputType.number,
                  textController: _codeController,
                  maxLength: 6,
                  isCenterText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (!RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')) {
                      return 'Enter the 6-digit code';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _approve(),
                ),
                addVerticalSpacing(3),
                AppButton(
                  text: 'Approve device',
                  onPressed: _approve,
                  isLoading: isLoading,
                  borderRadius: 16,
                  heightPercent: 6.4,
                ),
                addVerticalSpacing(1.5),
                AppButton(
                  text: 'Send a new code',
                  onPressed: isLoading || _resending ? null : _resend,
                  isLoading: _resending,
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
