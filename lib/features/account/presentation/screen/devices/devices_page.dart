import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/devices/registered_device.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/device_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/widget/device_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceControllerProvider);
    final value = devices.value;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const AppText(
          text: 'Signed-in devices',
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh devices',
            onPressed: value?.isRefreshing == true
                ? null
                : () => _refresh(context, ref),
            icon: value?.isRefreshing == true
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: devices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DeviceError(
          message: error.toString(),
          onRetry: () => ref.invalidate(deviceControllerProvider),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () => _refresh(context, ref),
          child: state.devices.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 120, 24, 32),
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 58,
                      color: colors.onSurfaceVariant,
                    ),
                    addVerticalSpacing(2),
                    AppText(
                      text: 'No registered devices',
                      type: AppTextType.titleMedium,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w700,
                    ),
                    addVerticalSpacing(0.875),
                    AppText(
                      text: 'Devices used to sign in will appear here.',
                      textAlign: TextAlign.center,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                  itemCount: state.devices.length,
                  itemBuilder: (context, index) {
                    final device = state.devices[index];
                    return DeviceTile(
                      device: device,
                      isRevoking: state.isRevoking(device.id),
                      onRevoke: () => _confirmRevoke(context, ref, device),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(deviceControllerProvider.notifier).refreshDevices();
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<void> _confirmRevoke(
    BuildContext context,
    WidgetRef ref,
    RegisteredDevice device,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText(
          text: 'Revoke this device?',
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w700,
        ),
        content: AppText(
          text:
              '${device.name} will be signed out and its active sessions will end.',
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(dialogContext, false),
            variant: AppButtonVariant.text,
            compact: true,
          ),
          AppButton(
            text: 'Revoke',
            onPressed: () => Navigator.pop(dialogContext, true),
            compact: true,
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(deviceControllerProvider.notifier).revokeDevice(device.id);
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  void _showFailure(BuildContext context, Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText(
            text: 'Unable to update devices: $error',
            color: AppColors.white,
          ),
        ),
      );
  }
}

class _DeviceError extends StatelessWidget {
  const _DeviceError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.devices_other, size: 48),
          addVerticalSpacing(1.5),
          AppText(
            text: message,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(2),
          AppButton(
            text: 'Try again',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            variant: AppButtonVariant.outlined,
            compact: true,
          ),
        ],
      ),
    ),
  );
}
