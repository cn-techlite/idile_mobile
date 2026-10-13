import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';

enum QuickAddType {
  bill,
  subscription,
  household,
  asset,
  document,
  maintenance,
}

Future<QuickAddType?> showQuickAddSheet(BuildContext context) =>
    showModalBottomSheet<QuickAddType>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.68,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).dividerColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              addVerticalSpacing(1.5),
              AppText.raw(
                'Add something new',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              addVerticalSpacing(0.625),
              const AppText.raw('Choose what you want to keep track of.'),
              addVerticalSpacing(2.5),
              Expanded(
                child: GridView.count(
                  physics: const ClampingScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.1,
                  children: [
                    _QuickAddItem(
                      label: 'Bill',
                      icon: Icons.receipt_long_outlined,
                      onTap: () =>
                          Navigator.pop(sheetContext, QuickAddType.bill),
                    ),
                    _QuickAddItem(
                      label: 'Subscription',
                      icon: Icons.autorenew,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        QuickAddType.subscription,
                      ),
                    ),
                    _QuickAddItem(
                      label: 'Household',
                      icon: Icons.inventory_2_outlined,
                      onTap: () =>
                          Navigator.pop(sheetContext, QuickAddType.household),
                    ),
                    _QuickAddItem(
                      label: 'Asset',
                      icon: Icons.laptop_mac_outlined,
                      onTap: () =>
                          Navigator.pop(sheetContext, QuickAddType.asset),
                    ),
                    _QuickAddItem(
                      label: 'Document',
                      icon: Icons.description_outlined,
                      onTap: () =>
                          Navigator.pop(sheetContext, QuickAddType.document),
                    ),
                    _QuickAddItem(
                      label: 'Maintenance',
                      icon: Icons.home_repair_service_outlined,
                      onTap: () =>
                          Navigator.pop(sheetContext, QuickAddType.maintenance),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

class _QuickAddItem extends StatelessWidget {
  const _QuickAddItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    return AppButton(
      text: label,
      onPressed: onTap,
      variant: AppButtonVariant.outlined,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: foreground),
            const SizedBox(width: 8),
            Flexible(
              child: AppText.raw(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
