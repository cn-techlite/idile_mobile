import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/app/router/route.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                compact ? 14 : 20,
                22,
                compact ? 12 : 20,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AppLogo(
                        markSize: compact ? 36 : 40,
                        nameSize: compact ? 27 : 30,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.signal.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.signal.withValues(alpha: .42),
                          ),
                        ),
                        child: AppText(
                          text: 'Made for home',
                          type: AppTextType.labelMedium,
                          color: onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(compact ? .5 : 1.25),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: .72,
                          colors: [
                            AppColors.signal.withValues(alpha: .23),
                            AppColors.signal.withValues(alpha: .07),
                            Colors.transparent,
                          ],
                          stops: const [0, .6, 1],
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/onboarding_home_system.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  addVerticalSpacing(compact ? 1 : 1.75),
                  AppText(
                    text: 'Your home, finally\nout of your head.',
                    type: AppTextType.headlineLarge,
                    textAlign: TextAlign.center,
                    color: onSurface,
                    fontSize: compact ? 30 : 36,
                    height: 1.03,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                  addVerticalSpacing(compact ? 1 : 1.5),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: AppText(
                      text:
                          'Bills, subscriptions, household upkeep and important '
                          'papers—kept together, so nothing turns urgent.',
                      type: AppTextType.bodyLarge,
                      textAlign: TextAlign.center,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      color: onSurface.withValues(alpha: .68),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!compact) ...[
                    addVerticalSpacing(2),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FeaturePill(icon: Icons.receipt_long, label: 'Bills'),
                        _FeaturePill(
                          icon: Icons.autorenew,
                          label: 'Subscriptions',
                        ),
                        _FeaturePill(
                          icon: Icons.home_repair_service,
                          label: 'Upkeep',
                        ),
                        _FeaturePill(
                          icon: Icons.folder_copy,
                          label: 'Documents',
                        ),
                      ],
                    ),
                  ],
                  addVerticalSpacing(compact ? 1.75 : 2.75),
                  AppButton(
                    text: 'Create your space',
                    fontSize: 15,
                    onPressed: () => navPush(context, RootRoutes.createAccount),
                  ),
                  addVerticalSpacing(1.5),
                  AppButton(
                    text: 'I already have an account',
                    fontSize: 14,
                    btnColor: Colors.transparent,
                    textColor: onSurface,
                    borderColor: onSurface.withValues(alpha: .28),
                    onPressed: () => navPush(context, RootRoutes.login),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: onSurface.withValues(alpha: .11)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: onSurface),
          addHorizontalSpacing(1.5),
          AppText(
            text: label,
            type: AppTextType.labelMedium,
            color: onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
