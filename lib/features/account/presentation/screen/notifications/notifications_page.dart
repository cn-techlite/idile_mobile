import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/notifications/in_app_notification.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/notification_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/notification_state.dart';
import 'package:idile_mobile_app/features/account/presentation/widget/notification_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(notificationControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _markRead(InAppNotification notification) async {
    if (notification.read) return;
    try {
      await ref
          .read(notificationControllerProvider.notifier)
          .markRead(notification.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: AppText(
              text: 'Unable to mark notification as read: $error',
              color: AppColors.white,
            ),
          ),
        );
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(notificationControllerProvider.notifier).markAllRead();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: AppText(
              text: 'Unable to mark all notifications as read: $error',
              color: AppColors.white,
            ),
          ),
        );
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationControllerProvider);
    final value = notifications.value;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const AppText(
          text: 'Notifications',
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppButton(
                text: 'Read all',
                onPressed:
                    value.isMarkingAllRead || value.markingReadIds.isNotEmpty
                    ? null
                    : _markAllRead,
                isLoading: value.isMarkingAllRead,
                variant: AppButtonVariant.text,
                compact: true,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _ReadFilter(
            selected: value?.readFilter,
            onChanged: (read) => ref
                .read(notificationControllerProvider.notifier)
                .setReadFilter(read),
          ),
          Expanded(child: _body(notifications, value)),
        ],
      ),
    );
  }

  Widget _body(
    AsyncValue<NotificationState> notifications,
    NotificationState? value,
  ) {
    final colors = Theme.of(context).colorScheme;
    if (notifications.isLoading && value == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifications.hasError && value == null) {
      return _InitialError(
        message: notifications.error.toString(),
        onRetry: () => ref.invalidate(notificationControllerProvider),
      );
    }
    final state = value ?? const NotificationState();
    if (state.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: ref
            .read(notificationControllerProvider.notifier)
            .refreshNotifications,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 32),
          children: [
            Icon(
              Icons.notifications_none,
              size: 58,
              color: colors.onSurfaceVariant,
            ),
            addVerticalSpacing(2),
            AppText(
              text: 'Nothing to show here',
              type: AppTextType.titleMedium,
              textAlign: TextAlign.center,
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            addVerticalSpacing(0.875),
            AppText(
              text: 'Your notifications will appear here.',
              textAlign: TextAlign.center,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      );
    }

    final showFooter =
        state.isLoadingMore || state.hasNextPage || state.loadMoreError != null;
    return RefreshIndicator(
      onRefresh: ref
          .read(notificationControllerProvider.notifier)
          .refreshNotifications,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: state.notifications.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.notifications.length) {
            final notification = state.notifications[index];
            return NotificationTile(
              notification: notification,
              isUpdating: state.isMarkingRead(notification.id),
              onTap: notification.read || state.isMarkingAllRead
                  ? null
                  : () => _markRead(notification),
            );
          }
          if (state.loadMoreError != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: AppButton(
                  text: 'Try loading more again',
                  onPressed: ref
                      .read(notificationControllerProvider.notifier)
                      .retryLoadMore,
                  icon: const Icon(Icons.refresh),
                  variant: AppButtonVariant.outlined,
                  compact: true,
                ),
              ),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class _ReadFilter extends StatelessWidget {
  const _ReadFilter({required this.selected, required this.onChanged});

  final bool? selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
    child: Row(
      children: [
        ChoiceChip(
          label: const AppText(text: 'All'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        addHorizontalSpacing(2),
        ChoiceChip(
          label: const AppText(text: 'Unread'),
          selected: selected == false,
          onSelected: (_) => onChanged(false),
        ),
        addHorizontalSpacing(2),
        ChoiceChip(
          label: const AppText(text: 'Read'),
          selected: selected == true,
          onSelected: (_) => onChanged(true),
        ),
      ],
    ),
  );
}

class _InitialError extends StatelessWidget {
  const _InitialError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
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
