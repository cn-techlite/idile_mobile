import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/home/data/model/hearth/hearth_models.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
    length: 6,
    child: Scaffold(
      appBar: AppBar(
        title: const AppText.raw('Admin'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Emails'),
            Tab(text: 'System'),
            Tab(text: 'Trends'),
            Tab(text: 'Audit'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          _Overview(),
          _Users(),
          _Emails(),
          _System(),
          _Trends(),
          _Audit(),
        ],
      ),
    ),
  );
}

class _Overview extends ConsumerWidget {
  const _Overview();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(adminStatsProvider)
      .when(
        loading: _loading,
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(adminStatsProvider),
        ),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Stat('Total users', stats.totalUsers),
                _Stat('Active users', stats.activeUsers),
                _Stat('New (30 days)', stats.newUsers),
                _Stat('Reminders today', stats.remindersToday),
              ],
            ),
            addVerticalSpacing(3),
            AppText.raw(
              'Items across Ìdílé',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            addVerticalSpacing(1.25),
            Card(
              child: Column(
                children: stats.items.entries
                    .map(
                      (e) => ListTile(
                        title: AppText.raw(e.key),
                        trailing: AppText.raw(
                          '${e.value}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
}

class _Users extends ConsumerWidget {
  const _Users();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(adminUsersProvider)
      .when(
        loading: _loading,
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
        data: (users) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final user = users[index];
            final disabled = user.disabledAt != null;
            return ListTile(
              title: AppText.raw(user.name.isEmpty ? user.email : user.name),
              subtitle: AppText.raw('${user.email} · ${user.role}'),
              trailing: Switch(
                value: !disabled,
                onChanged: (enabled) async {
                  try {
                    await ref
                        .read(hearthRepositoryProvider)
                        .setUserDisabled(user.id, !enabled);
                    ref.invalidate(adminUsersProvider);
                  } catch (e) {
                    if (context.mounted) showFailure(context, e);
                  }
                },
              ),
            );
          },
        ),
      );
}

class _Emails extends ConsumerWidget {
  const _Emails();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(adminEmailsProvider)
      .when(
        loading: _loading,
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(adminEmailsProvider),
        ),
        data: (emails) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: emails.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final email = emails[index];
            return ListTile(
              title: AppText.raw(email.subject),
              subtitle: AppText.raw('${email.to} · ${email.attempts} attempts'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusPill(email.status),
                  if (email.status == 'failed')
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(hearthRepositoryProvider)
                            .retryEmail(email.id);
                        ref.invalidate(adminEmailsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                ],
              ),
            );
          },
        ),
      );
}

class _System extends ConsumerWidget {
  const _System();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(adminHealthProvider)
      .when(
        loading: _loading,
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(adminHealthProvider),
        ),
        data: (health) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const AppText.raw('Database'),
                    trailing: StatusPill(health.database),
                  ),
                  ListTile(
                    title: const AppText.raw('Pending emails'),
                    trailing: AppText.raw('${health.pendingEmails}'),
                  ),
                  ListTile(
                    title: const AppText.raw('Failed emails (24h)'),
                    trailing: AppText.raw('${health.failedEmails}'),
                  ),
                  ListTile(
                    title: const AppText.raw('Resend webhook'),
                    trailing: Icon(
                      health.webhookConfigured
                          ? Icons.check_circle
                          : Icons.error_outline,
                    ),
                  ),
                ],
              ),
            ),
            addVerticalSpacing(2),
            AppButton(
              text: 'Run reminder sweep',
              onPressed: () async {
                try {
                  await ref.read(hearthRepositoryProvider).runReminderSweep();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: AppText.raw('Reminder sweep started'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) showFailure(context, e);
                }
              },
              icon: const Icon(Icons.notifications_active_outlined),
            ),
          ],
        ),
      );
}

class _Trends extends ConsumerWidget {
  const _Trends();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(adminTrendsProvider)
      .when(
        loading: _loading,
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(adminTrendsProvider),
        ),
        data: (trends) => _JsonList(data: trends),
      );
}

class _Audit extends ConsumerWidget {
  const _Audit();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(adminAuditProvider)
      .when(
        loading: _loading,
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(adminAuditProvider),
        ),
        data: (entries) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final item = entries[index];
            return Card(
              child: ListTile(
                title: AppText.raw('${item['action'] ?? 'Action'}'),
                subtitle: AppText.raw(
                  '${item['targetType'] ?? ''} · ${shortDate('${item['createdAt'] ?? ''}')}',
                ),
              ),
            );
          },
        ),
      );
}

class _JsonList extends StatelessWidget {
  const _JsonList({required this.data});
  final Json data;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: data.entries
        .map(
          (entry) => Card(
            child: ListTile(
              title: AppText.raw(entry.key),
              subtitle: AppText.raw(
                '${entry.value}',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 160,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.raw(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            AppText.raw(label),
          ],
        ),
      ),
    ),
  );
}

Widget _loading() => const Center(child: CircularProgressIndicator());
