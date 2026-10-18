import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notifications/in_app_notification.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.isUpdating = false,
  });

  final InAppNotification notification;
  final VoidCallback? onTap;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    color: notification.read ? null : AppColors.signal.withValues(alpha: .09),
    child: InkWell(
      onTap: isUpdating ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: notification.read
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : AppColors.signal,
              foregroundColor: AppColors.ink,
              child: Icon(_icon(notification.type), size: 20),
            ),
            addHorizontalSpacing(3.25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          text: notification.title,
                          type: AppTextType.titleSmall,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: notification.read
                              ? FontWeight.w600
                              : FontWeight.w800,
                        ),
                      ),
                      if (isUpdating)
                        const Padding(
                          padding: EdgeInsets.only(top: 1, left: 8),
                          child: SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 5, left: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.signal,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  addVerticalSpacing(0.625),
                  AppText(
                    text: notification.message,
                    type: AppTextType.bodyMedium,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  if (notification.createdAt != null) ...[
                    addVerticalSpacing(1.125),
                    AppText(
                      text: DateFormat('d MMM yyyy, h:mm a')
                          .format(notification.createdAt!.toLocal()),
                      type: AppTextType.labelSmall,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  IconData _icon(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('bill')) return Icons.receipt_long_outlined;
    if (normalized.contains('subscription')) return Icons.autorenew;
    if (normalized.contains('maintenance')) return Icons.build_outlined;
    if (normalized.contains('expiry')) return Icons.event_busy_outlined;
    return Icons.notifications_none;
  }
}
