// ignore_for_file: deprecated_member_use

import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/package_export.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';

class GlobalBackButton extends StatelessWidget {
  const GlobalBackButton({
    super.key,
    this.backText,
    this.buttonElements,
    this.color,
    this.showBackButton = true,
  });

  final String? backText;
  final bool showBackButton;
  final Color? color;
  final List<Widget>? buttonElements;

  @override
  Widget build(BuildContext context) {
    // TextScaler textScaler = MediaQuery.of(context).textScaler;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 3.heightAdjusted),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                addHorizontalSpacing(3),
                Row(
                  children: [
                    showBackButton
                        ? InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: SvgPicture.asset(
                                  'assets/svgs/back_button.svg',
                                  width: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : addHorizontalSpacing(6),
                    addVerticalSpacing(1.heightAdjusted),
                    AppText(
                      isBody: true,
                      text: backText ?? "",
                      textAlign: TextAlign.start,
                      fontSize: 18,
                      color: color ?? Theme.of(context).colorScheme.onSurface,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                const Spacer(),
                Row(children: buttonElements ?? []),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

AppBar buildFlexibleAppBar({
  required BuildContext context,
  String backIconAsset = 'assets/svgs/back_button.svg',
  double iconWidth = 15.0,
  VoidCallback? onBack,
  Color? backgroundColor,
  Color? surfaceTintColor,
  Color? foregroundColor,
  bool showBackButton = true,
  Widget? title,
  List<Widget>? actions,
  Widget? bottomWidget, // e.g. Search bar, filter chips
  double bottomHeight = 56.0,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return AppBar(
    automaticallyImplyLeading: false,
    centerTitle: false,
    backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
    surfaceTintColor: surfaceTintColor ?? Colors.transparent,
    foregroundColor: foregroundColor ?? colors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: showBackButton
        ? IconButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: SvgPicture.asset(
              backIconAsset,
              width: iconWidth,
              colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
            ),
          )
        : null,
    title: title ?? const AppLogo(markSize: 30, nameSize: 23),
    actions: actions,
    bottom: bottomWidget != null
        ? PreferredSize(
            preferredSize: Size.fromHeight(bottomHeight),
            child: bottomWidget,
          )
        : null,
  );
}
