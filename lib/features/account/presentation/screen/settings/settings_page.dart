import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/router/route.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/update_account_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/upload_avatar_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/reminders/update_reminder_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notification_settings/update_notification_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/reminders/reminder_settings.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/categories/categories_page.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/devices/devices_page.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/spaces/spaces_page.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/account_provider.dart';
import 'package:idile_mobile_app/features/auth/presentation/state/providers/auth_providers.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/shared/providers/theme_state.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/attachment_picker.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountControllerProvider).value;
    final sessionState = ref.watch(sessionControllerProvider);
    final user = accountState?.profile;
    final isUpdating = accountState?.isUpdating ?? false;
    final isUploadingAvatar = accountState?.isUploadingAvatar ?? false;
    final catalogState = ref.watch(catalogControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const AppText.raw('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Card(
            child: ListTile(
              leading: _ProfileAvatarButton(
                user: user,
                isLoading: isUploadingAvatar,
                onTap: user == null || isUploadingAvatar
                    ? null
                    : () => _uploadAvatar(context, ref),
              ),
              title: AppText.raw(
                user?.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: AppText.raw(user?.email ?? ''),
              trailing: IconButton(
                onPressed: user == null || isUpdating
                    ? null
                    : () => _rename(context, ref, user),
                icon: isUpdating
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined),
              ),
            ),
          ),
          addVerticalSpacing(2),
          AppText.raw(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          addVerticalSpacing(1),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: AppText.raw('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: AppText.raw('Light'),
              ),
              ButtonSegment(value: ThemeMode.dark, label: AppText.raw('Dark')),
            ],
            selected: {ref.watch(themeNotifierProvider)},
            onSelectionChanged: (modes) =>
                ref.read(themeNotifierProvider.notifier).setTheme(modes.first),
          ),
          addVerticalSpacing(2.5),
          catalogState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorState(
              error: e,
              onRetry: () => ref.invalidate(catalogControllerProvider),
            ),
            data: (catalog) => Column(
              children: [
                _section(
                  context,
                  icon: Icons.currency_exchange,
                  title: 'Default currency',
                  child: GlobalSearchableDropdown<String>(
                    key: ValueKey(user?.defaultCurrencyId),
                    title: 'Display currency',
                    hintText: 'Choose currency',
                    value:
                        catalog.currencies.any(
                          (currency) => currency.id == user?.defaultCurrencyId,
                        )
                        ? user?.defaultCurrencyId
                        : null,
                    options: [
                      for (final currency in catalog.currencies)
                        SearchableDropdownOption(
                          value: currency.id,
                          label: '${currency.symbol} ${currency.name}',
                        ),
                    ],
                    enabled: !isUpdating,
                    onChanged: (value) => _updateProfile(
                      context,
                      ref,
                      UpdateAccountRequest(defaultCurrencyId: value),
                    ),
                  ),
                ),
                _section(
                  context,
                  icon: Icons.home_work_outlined,
                  title: 'Default spaces',
                  child: Column(
                    children: [
                      _spaceDropdown(
                        label: 'Default space',
                        selectedId: user?.defaultSpaceId,
                        spaces: catalog.spaces
                            .map((space) => (id: space.id, name: space.name))
                            .toList(),
                        enabled: !isUpdating,
                        onChanged: (value) => _updateProfile(
                          context,
                          ref,
                          UpdateAccountRequest(defaultSpaceId: value),
                        ),
                      ),
                      addVerticalSpacing(1.5),
                      _spaceDropdown(
                        label: 'Household space',
                        selectedId: user?.householdSpaceId,
                        spaces: catalog.spaces
                            .map((space) => (id: space.id, name: space.name))
                            .toList(),
                        enabled: !isUpdating,
                        onChanged: (value) => _updateProfile(
                          context,
                          ref,
                          UpdateAccountRequest(householdSpaceId: value),
                        ),
                      ),
                      addVerticalSpacing(1.5),
                      _spaceDropdown(
                        label: 'Workspace space',
                        selectedId: user?.workspaceSpaceId,
                        spaces: catalog.spaces
                            .map((space) => (id: space.id, name: space.name))
                            .toList(),
                        enabled: !isUpdating,
                        onChanged: (value) => _updateProfile(
                          context,
                          ref,
                          UpdateAccountRequest(workspaceSpaceId: value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SpacesSection(),
          _CategoriesSection(),
          _ReminderSection(),
          _NotificationSection(),
          _DevicesSection(),
          addVerticalSpacing(1.5),
          AppButton(
            text: 'Sign out',
            onPressed: sessionState.isLoading
                ? null
                : () => _confirmLogout(context, ref),
            isLoading: sessionState.isLoading,
            icon: const Icon(Icons.logout),
            variant: AppButtonVariant.outlined,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.logout, color: colors.error),
          title: const AppText.raw('Sign out?'),
          content: const AppText.raw(
            'You will need to sign in again to access your account.',
          ),
          actions: [
            AppButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext, false),
              variant: AppButtonVariant.text,
              compact: true,
            ),
            AppButton(
              text: 'Sign out',
              onPressed: () => Navigator.pop(dialogContext, true),
              btnColor: colors.error,
              textColor: colors.onError,
              compact: true,
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _logout(context, ref);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(sessionControllerProvider.notifier).logout();
    } catch (error) {
      debugPrint('Remote sign-out failed after local session cleanup: $error');
    } finally {
      ref.read(accountControllerProvider.notifier).clear();
      if (context.mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(RootRoutes.login, (_) => false);
      }
    }
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              addHorizontalSpacing(2.5),
              AppText.raw(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          addVerticalSpacing(1.75),
          child,
        ],
      ),
    ),
  );

  Widget _spaceDropdown({
    required String label,
    required String? selectedId,
    required List<({String id, String name})> spaces,
    required bool enabled,
    required Future<void> Function(String) onChanged,
  }) {
    final availableIds = spaces.map((space) => space.id).toSet();
    final value = availableIds.contains(selectedId) ? selectedId : null;
    return GlobalSearchableDropdown<String>(
      key: ValueKey('$label-$value'),
      title: label,
      hintText: 'Choose a space',
      value: value,
      options: [
        for (final space in spaces)
          SearchableDropdownOption(value: space.id, label: space.name),
      ],
      enabled: enabled,
      onChanged: onChanged,
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    UserProfile user,
  ) async {
    final controller = TextEditingController(text: user.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText.raw('Edit profile'),
        content: GlobalTextField(
          fieldName: 'Name',
          keyBoardType: TextInputType.name,
          textController: controller,
          autofocus: true,
          removeSpace: false,
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            variant: AppButtonVariant.text,
            compact: true,
          ),
          AppButton(
            text: 'Save',
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            compact: true,
          ),
        ],
      ),
    );
    controller.dispose();
    if (name?.isNotEmpty == true && context.mounted) {
      await _updateProfile(context, ref, UpdateAccountRequest(name: name));
    }
  }

  Future<void> _updateProfile(
    BuildContext context,
    WidgetRef ref,
    UpdateAccountRequest request,
  ) async {
    try {
      await ref.read(accountControllerProvider.notifier).updateProfile(request);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }

  Future<void> _uploadAvatar(BuildContext context, WidgetRef ref) async {
    final attachment = await showAttachmentPicker(
      context,
      maxFileSizeBytes: UploadAvatarRequest.maxFileSizeBytes,
      allowedExtensions: UploadAvatarRequest.allowedExtensions,
    );
    if (attachment == null || !context.mounted) return;

    try {
      await ref
          .read(accountControllerProvider.notifier)
          .uploadAvatar(
            UploadAvatarRequest(
              fileBytes: await attachment.readAsBytes(),
              fileName: attachment.name,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText.raw('Profile photo updated.')),
        );
      }
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({
    required this.user,
    required this.isLoading,
    required this.onTap,
  });

  final UserProfile? user;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl?.trim();
    final image = avatarUrl == null || avatarUrl.isEmpty
        ? null
        : NetworkImage(avatarUrl);
    final initial = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'Ì';
    return Semantics(
      button: true,
      label: 'Change profile photo',
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox.square(
          dimension: 52,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.signal,
                foregroundImage: image,
                onForegroundImageError: image == null ? null : (_, _) {},
                child: AppText.raw(
                  initial,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.scrim
                          .withValues(alpha: .45),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              if (!isLoading)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 13,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountControllerProvider);
    final accountState = account.value;
    final settings = accountState?.reminderSettings;
    final isLoading =
        account.isLoading || (accountState?.isLoadingReminderSettings ?? false);
    final error = account.hasError
        ? account.error.toString()
        : accountState?.reminderSettingsError;

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.notifications_active_outlined),
        title: const AppText.raw(
          'Reminders',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (error != null)
            ListTile(
              title: AppText(text: error),
              trailing: IconButton(
                tooltip: 'Retry',
                onPressed: () => ref
                    .read(accountControllerProvider.notifier)
                    .refreshReminderSettings(),
                icon: const Icon(Icons.refresh),
              ),
            )
          else if (settings == null)
            ListTile(
              title: const AppText(text: 'Reminder settings are unavailable.'),
              trailing: IconButton(
                tooltip: 'Retry',
                onPressed: () => ref
                    .read(accountControllerProvider.notifier)
                    .refreshReminderSettings(),
                icon: const Icon(Icons.refresh),
              ),
            )
          else
            Column(
              children: settings.entries.entries
                  .map(
                    (entry) => SwitchListTile(
                      title: AppText(text: entry.key.displayName),
                      subtitle: AppText.raw(
                        entry.value.leadDays.isEmpty
                            ? 'On the due date'
                            : '${entry.value.leadDays.join(', ')} days before',
                      ),
                      value: entry.value.enabled,
                      onChanged: (enabled) async {
                        try {
                          await ref
                              .read(accountControllerProvider.notifier)
                              .updateReminderSettings(
                                UpdateReminderSettingsRequest.forKind(
                                  entry.key,
                                  ReminderPreference(
                                    enabled: enabled,
                                    leadDays: entry.value.leadDays,
                                  ),
                                ),
                              );
                        } catch (e) {
                          if (context.mounted) showFailure(context, e);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DevicesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.devices_outlined),
      title: const AppText.raw(
        'Signed-in devices',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: const AppText(text: 'Review and revoke registered devices'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const DevicesPage()),
      ),
    ),
  );
}

class _SpacesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: ListTile(
      leading: const Icon(Icons.space_dashboard_outlined),
      title: const AppText(text: 'Spaces', fontWeight: FontWeight.w700),
      subtitle: const AppText(
        text: 'Create and manage your homes and workplaces',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const SpacesPage()),
        );
        ref.invalidate(catalogControllerProvider);
      },
    ),
  );
}

class _CategoriesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: ListTile(
      leading: const Icon(Icons.category_outlined),
      title: const AppText(text: 'Categories', fontWeight: FontWeight.w700),
      subtitle: const AppText(text: 'Organise bills by category'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const CategoriesPage()),
        );
        ref.invalidate(catalogControllerProvider);
      },
    ),
  );
}

class _NotificationSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountControllerProvider);
    final accountState = account.value;
    final settings = accountState?.notificationSettings;
    final isLoading =
        account.isLoading ||
        (accountState?.isLoadingNotificationSettings ?? false);
    final error = account.hasError
        ? account.error.toString()
        : accountState?.notificationSettingsError;

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.mark_email_read_outlined),
        title: const AppText(
          text: 'Notifications',
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (error != null)
            ListTile(
              title: AppText(text: error),
              trailing: IconButton(
                tooltip: 'Retry',
                onPressed: () => ref
                    .read(accountControllerProvider.notifier)
                    .refreshNotificationSettings(),
                icon: const Icon(Icons.refresh),
              ),
            )
          else if (settings == null)
            ListTile(
              title: const AppText(
                text: 'Notification settings are unavailable.',
              ),
              trailing: IconButton(
                tooltip: 'Retry',
                onPressed: () => ref
                    .read(accountControllerProvider.notifier)
                    .refreshNotificationSettings(),
                icon: const Icon(Icons.refresh),
              ),
            )
          else
            Column(
              children: [
                SwitchListTile(
                  title: const AppText(text: 'In-app notifications'),
                  value: settings.channels.inApp,
                  onChanged: (value) => _update(
                    context,
                    ref,
                    UpdateNotificationSettingsRequest(channelInApp: value),
                  ),
                ),
                SwitchListTile(
                  title: const AppText(text: 'Email notifications'),
                  value: settings.channels.email,
                  onChanged: (value) => _update(
                    context,
                    ref,
                    UpdateNotificationSettingsRequest(channelEmail: value),
                  ),
                ),
                SwitchListTile(
                  title: const AppText(text: 'Quiet hours'),
                  subtitle: AppText(
                    text:
                        '${settings.quietHours.from} – ${settings.quietHours.to}',
                  ),
                  value: settings.quietHours.enabled,
                  secondary: IconButton(
                    tooltip: 'Change quiet hours',
                    onPressed: () => _editQuietHours(
                      context,
                      ref,
                      settings.quietHours.from,
                      settings.quietHours.to,
                    ),
                    icon: const Icon(Icons.schedule_outlined),
                  ),
                  onChanged: (value) => _update(
                    context,
                    ref,
                    UpdateNotificationSettingsRequest(quietHoursEnabled: value),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    UpdateNotificationSettingsRequest request,
  ) async {
    try {
      await ref
          .read(accountControllerProvider.notifier)
          .updateNotificationSettings(request);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }

  Future<void> _editQuietHours(
    BuildContext context,
    WidgetRef ref,
    String currentFrom,
    String currentTo,
  ) async {
    final from = await showTimePicker(
      context: context,
      initialTime: _parseTime(
        currentFrom,
        const TimeOfDay(hour: 22, minute: 0),
      ),
      helpText: 'Quiet hours start',
    );
    if (from == null || !context.mounted) return;
    final to = await showTimePicker(
      context: context,
      initialTime: _parseTime(currentTo, const TimeOfDay(hour: 7, minute: 0)),
      helpText: 'Quiet hours end',
    );
    if (to == null || !context.mounted) return;
    await _update(
      context,
      ref,
      UpdateNotificationSettingsRequest(
        quietHoursFrom: _formatTime(from),
        quietHoursTo: _formatTime(to),
      ),
    );
  }

  TimeOfDay _parseTime(String value, TimeOfDay fallback) {
    final parts = value.split(':');
    if (parts.length != 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return fallback;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
