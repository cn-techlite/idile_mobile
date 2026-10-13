import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/settings/settings_page.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/notifications/notifications_page.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/account_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/admin/admin_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/assets/assets_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/calendar/calendar_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/documents/documents_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/household/household_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/payments/payments_page.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(accountControllerProvider).value?.profile;
    final entries = <({String label, IconData icon, Widget page})>[
      (
        label: 'Household',
        icon: Icons.inventory_2_outlined,
        page: const HouseholdPage(),
      ),
      (
        label: 'Assets',
        icon: Icons.laptop_mac_outlined,
        page: const AssetsPage(),
      ),
      (
        label: 'Documents',
        icon: Icons.description_outlined,
        page: const DocumentsPage(),
      ),
      (
        label: 'Calendar',
        icon: Icons.calendar_month_outlined,
        page: const CalendarPage(),
      ),
      (
        label: 'Payments',
        icon: Icons.payments_outlined,
        page: const PaymentsPage(),
      ),
      (
        label: 'Notifications',
        icon: Icons.notifications_none,
        page: const NotificationsPage(),
      ),
      (
        label: 'Account',
        icon: Icons.manage_accounts_outlined,
        page: const SettingsPage(),
      ),
      if (user?.role == 'admin')
        (
          label: 'Admin',
          icon: Icons.admin_panel_settings_outlined,
          page: const AdminPage(),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Row(
          children: [
            const AppLogo(markSize: 42, showName: false),
            addHorizontalSpacing(3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.raw(
                  user?.name ?? 'Ìdílé',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                AppText.raw(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        addVerticalSpacing(3.25),
        AppText.raw('More', style: Theme.of(context).textTheme.headlineMedium),
        addVerticalSpacing(1.75),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final item = entries[index];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.icon, size: 30),
                      AppText.raw(
                        item.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
