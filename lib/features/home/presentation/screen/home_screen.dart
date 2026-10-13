import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/notifications/notifications_page.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/settings/settings_page.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/account_provider.dart';
import 'package:idile_mobile_app/features/bills/presentation/screen/bills/bills_page.dart';
import 'package:idile_mobile_app/features/home/presentation/screen/dashboard/dashboard_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/assets/assets_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/documents/documents_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/household/household_page.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/more_page.dart';
import 'package:idile_mobile_app/features/home/presentation/widget/quick_add/quick_add_sheet.dart';
import 'package:idile_mobile_app/features/subs/presentation/screen/subscriptions/subscriptions_page.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';

class HomeScreenPage extends ConsumerStatefulWidget {
  const HomeScreenPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends ConsumerState<HomeScreenPage> {
  late int index = widget.initialIndex.clamp(0, 3);
  final _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());
  final _tabHasSubroute = List.filled(4, false);
  late final List<NavigatorObserver> _navigatorObservers;

  static const pages = [
    DashboardPage(),
    BillsPage(),
    SubscriptionsPage(),
    MorePage(),
  ];

  bool get _activeTabHasSubroute => _tabHasSubroute[index];

  @override
  void initState() {
    super.initState();
    _navigatorObservers = List.generate(
      pages.length,
      (tabIndex) => _TabNavigatorObserver(
        (canPop) => _setTabHasSubroute(tabIndex, canPop),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HomeScreenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      index = widget.initialIndex.clamp(0, pages.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_activeTabHasSubroute,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _activeTabHasSubroute) {
        _navigatorKeys[index].currentState?.pop();
      }
    },
    child: Scaffold(
      extendBody: !_activeTabHasSubroute,
      appBar: _activeTabHasSubroute ? null : _appBar(context),
      body: SafeArea(
        top: !_activeTabHasSubroute,
        bottom: false,
        child: IndexedStack(
          index: index,
          children: List.generate(
            pages.length,
            (tabIndex) => Navigator(
              key: _navigatorKeys[tabIndex],
              observers: [_navigatorObservers[tabIndex]],
              onGenerateRoute: (_) =>
                  MaterialPageRoute<void>(builder: (_) => pages[tabIndex]),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _activeTabHasSubroute
          ? null
          : FloatingActionButton(
              heroTag: 'home-quick-add-fab',
              backgroundColor: AppColors.signal,
              foregroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.ink, width: 4),
              ),
              onPressed: _showQuickAdd,
              tooltip: 'Quick add',
              child: const Icon(Icons.add, size: 30),
            ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.ink,
        shape: _activeTabHasSubroute ? null : const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 76,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                selected: index == 0,
                onTap: () => _selectTab(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                label: 'Bills',
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                selected: index == 1,
                onTap: () => _selectTab(1),
              ),
            ),
            if (!_activeTabHasSubroute) addHorizontalSpacing(16),
            Expanded(
              child: _NavItem(
                label: 'Subs',
                icon: Icons.autorenew,
                selectedIcon: Icons.paid,
                selected: index == 2,
                onTap: () => _selectTab(2),
              ),
            ),
            Expanded(
              child: _NavItem(
                label: 'More',
                icon: Icons.menu,
                selectedIcon: Icons.menu_open,
                selected: index == 3,
                onTap: () => _selectTab(3),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _setTabHasSubroute(int tabIndex, bool hasSubroute) {
    if (!mounted || _tabHasSubroute[tabIndex] == hasSubroute) return;
    setState(() => _tabHasSubroute[tabIndex] = hasSubroute);
  }

  void _selectTab(int selectedIndex) {
    if (selectedIndex == index && _tabHasSubroute[selectedIndex]) {
      _navigatorKeys[selectedIndex].currentState?.popUntil(
        (route) => route.isFirst,
      );
      return;
    }
    setState(() => index = selectedIndex);
  }

  Future<void> _showQuickAdd() async {
    final navigatorContext =
        _navigatorKeys[index].currentState?.overlay?.context ?? context;
    final selection = await showQuickAddSheet(navigatorContext);
    if (!mounted || selection == null) return;

    switch (selection) {
      case QuickAddType.bill:
        await _openQuickAddForm(1, showCreateBillForm);
      case QuickAddType.subscription:
        await _openQuickAddForm(2, showCreateSubscriptionForm);
      case QuickAddType.household:
        await _openQuickAddForm(3, showCreateHouseholdItemForm);
      case QuickAddType.asset:
        await _openQuickAddForm(3, showCreateAssetForm);
      case QuickAddType.document:
        await _openQuickAddForm(3, showCreateDocumentForm);
      case QuickAddType.maintenance:
        await _openQuickAddForm(3, showCreateMaintenanceForm);
    }
  }

  Future<void> _openQuickAddForm(
    int targetTab,
    Future<void> Function(BuildContext, WidgetRef) openForm,
  ) async {
    if (index != targetTab) setState(() => index = targetTab);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final navigatorContext =
        _navigatorKeys[targetTab].currentState?.overlay?.context;
    if (navigatorContext == null || !navigatorContext.mounted) return;
    await openForm(navigatorContext, ref);
  }

  void _pushOnActiveTab(Widget page) {
    _navigatorKeys[index].currentState?.push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final profile = ref.watch(accountControllerProvider).value?.profile;
    final avatarUrl = profile?.avatarUrl?.trim();
    final onHome = index == 0;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: onHome ? 78 : kToolbarHeight,
      title: AppLogo(markSize: onHome ? 42 : 32, nameSize: onHome ? 30 : 25),
      shape: onHome
          ? Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: .3),
              ),
            )
          : null,
      actions: onHome
          ? [
              IconButton(
                tooltip: 'Search',
                onPressed: () => showSearch<void>(
                  context: context,
                  delegate: _HomeSearchDelegate(
                    onSelected: (selected) => setState(() => index = selected),
                  ),
                ),
                icon: const Icon(Icons.search, size: 28),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => _pushOnActiveTab(const NotificationsPage()),
                icon: const Icon(Icons.notifications_none, size: 28),
              ),
              addHorizontalSpacing(1),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _pushOnActiveTab(const SettingsPage()),
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? AppText(
                            text: _initials(profile?.name),
                            type: AppTextType.titleMedium,
                            fontWeight: FontWeight.w900,
                          )
                        : Image.network(
                            avatarUrl,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => AppText(
                              text: _initials(profile?.name),
                              type: AppTextType.titleMedium,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ]
          : null,
    );
  }
}

class _TabNavigatorObserver extends NavigatorObserver {
  _TabNavigatorObserver(this.onStackChanged);

  final ValueChanged<bool> onStackChanged;

  void _notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = navigator;
      if (state != null) onStackChanged(state.canPop());
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _notify();
  }
}

String _initials(String? name) {
  final words = name
      ?.trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words == null || words.isEmpty) return 'Ì';
  if (words.length == 1) {
    return words.first
        .substring(0, words.first.length.clamp(1, 2))
        .toUpperCase();
  }
  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

class _HomeSearchDelegate extends SearchDelegate<void> {
  _HomeSearchDelegate({required this.onSelected});

  final ValueChanged<int> onSelected;

  static const _destinations = <({String label, IconData icon, int index})>[
    (label: 'Home', icon: Icons.home_outlined, index: 0),
    (label: 'Bills', icon: Icons.receipt_long_outlined, index: 1),
    (label: 'Subscriptions', icon: Icons.autorenew, index: 2),
    (label: 'More', icon: Icons.menu, index: 3),
  ];

  @override
  String get searchFieldLabel => 'Search Ìdílé';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Clear',
        onPressed: () => query = '',
        icon: const Icon(Icons.close),
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: 'Back',
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final matches = _destinations
        .where(
          (destination) =>
              normalized.isEmpty ||
              destination.label.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
    if (matches.isEmpty) {
      return const Center(child: AppText.raw('No matching section'));
    }
    return ListView(
      children: [
        for (final destination in matches)
          ListTile(
            leading: Icon(destination.icon),
            title: AppText.raw(destination.label),
            onTap: () {
              close(context, null);
              onSelected(destination.index);
            },
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon, selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          selected ? selectedIcon : icon,
          color: selected ? AppColors.signal : AppColors.paper,
        ),
        addVerticalSpacing(0.375),
        AppText(
          text: label,
          type: AppTextType.labelSmall,
          color: selected ? AppColors.signal : AppColors.paper,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ],
    ),
  );
}
