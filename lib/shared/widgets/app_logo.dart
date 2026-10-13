import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

/// The shared Ìdílé brand lockup.
///
/// The mark follows the web brand: an `Ì` on an ink plate. Yellow is kept for
/// attention states elsewhere in the product and is deliberately not used in
/// the logo.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.markSize = 40,
    this.nameSize = 30,
    this.showName = true,
    this.markColor,
    this.markTextColor,
    this.nameColor,
  });

  final double markSize;
  final double nameSize;
  final bool showName;
  final Color? markColor;
  final Color? markTextColor;
  final Color? nameColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plateColor = markColor ?? (isDark ? AppColors.paper : AppColors.ink);
    final letterColor =
        markTextColor ?? (isDark ? AppColors.ink : AppColors.paper);
    final wordmarkColor =
        nameColor ?? (isDark ? AppColors.paper : AppColors.ink);

    return Semantics(
      label: 'Ìdílé',
      image: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: markSize,
            height: markSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: plateColor,
              borderRadius: BorderRadius.circular(markSize * .14),
            ),
            child: AppText(
              text: 'Ì',
              type: AppTextType.headlineMedium,
              color: letterColor,
              fontFamily: 'Open Serif',
              fontSize: markSize * .68,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showName) ...[
            addHorizontalSpacing(2.4),
            AppText(
              text: 'Ìdílé',
              type: AppTextType.headlineMedium,
              color: wordmarkColor,
              fontFamily: 'Open Serif',
              fontSize: nameSize,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ],
        ],
      ),
    );
  }
}
