import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/entities/devices/registered_device.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:intl/intl.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.device,
    required this.onRevoke,
    this.isRevoking = false,
  });

  final RegisteredDevice device;
  final VoidCallback onRevoke;
  final bool isRevoking;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            child: Icon(_platformIcon(device.platform)),
          ),
          addHorizontalSpacing(3.25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: device.name,
                        type: AppTextType.titleMedium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _StatusChip(status: device.status),
                  ],
                ),
                addVerticalSpacing(0.625),
                AppText(
                  text: _platformLabel(device.platform),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (device.lastUsedAt != null) ...[
                  addVerticalSpacing(0.625),
                  AppText(
                    text:
                        'Last used ${DateFormat('d MMM yyyy, h:mm a').format(device.lastUsedAt!.toLocal())}',
                    type: AppTextType.bodySmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ] else if (device.createdAt != null) ...[
                  addVerticalSpacing(0.625),
                  AppText(
                    text:
                        'Added ${DateFormat('d MMM yyyy').format(device.createdAt!.toLocal())}',
                    type: AppTextType.bodySmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
                if (device.canRevoke) ...[
                  addVerticalSpacing(1.5),
                  AppButton(
                    text: 'Revoke device',
                    onPressed: isRevoking ? null : onRevoke,
                    icon: const Icon(Icons.block_outlined),
                    isLoading: isRevoking,
                    variant: AppButtonVariant.outlined,
                    compact: true,
                    borderColor: AppColors.danger,
                    textColor: AppColors.danger,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );

  IconData _platformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.android;
      case 'web':
        return Icons.language;
      default:
        return Icons.devices_other;
    }
  }

  String _platformLabel(String platform) => switch (platform.toLowerCase()) {
    'ios' => 'iOS',
    'android' => 'Android',
    'web' => 'Web',
    _ => platform.isEmpty ? 'Unknown platform' : platform,
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'approved' => AppColors.success,
      'revoked' => AppColors.danger,
      _ => AppColors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AppText(
        text: normalized.isEmpty
            ? 'Unknown'
            : '${normalized[0].toUpperCase()}${normalized.substring(1)}',
        type: AppTextType.labelSmall,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
