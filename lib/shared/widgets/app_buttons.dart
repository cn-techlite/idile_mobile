import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double widthPercent;
  final double heightPercent;
  final Color? btnColor;
  final bool isLoading;
  final Color? textColor;
  final double fontSize;
  final double borderRadius;
  final bool safeArea;
  final List<Color> gradientColors;
  final bool isGradient;
  final Widget? child;
  final Widget? icon;
  final AppButtonVariant variant;
  final bool compact;
  final Color? borderColor;
  final double borderWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.widthPercent = 100,
    this.heightPercent = 6,
    this.btnColor,
    this.isLoading = false,
    this.textColor,
    this.fontSize = 12,
    this.borderRadius = 14,
    this.safeArea = false,
    this.gradientColors = const [Color(0xFF65D6CE), Color(0xFF2980B9)],
    this.isGradient = false,
    this.child,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.compact = false,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = onPressed == null && !isLoading;

    final effectiveButtonColor = _resolveButtonColor(
      colorScheme: colorScheme,
      isDark: isDark,
      isDisabled: isDisabled,
    );
    final effectiveTextColor = _resolveTextColor(
      colorScheme: colorScheme,
      isDark: isDark,
      isDisabled: isDisabled,
      effectiveButtonColor: effectiveButtonColor,
    );
    final effectiveBorderColor = _resolveBorderColor(
      colorScheme: colorScheme,
      isDark: isDark,
      isDisabled: isDisabled,
    );

    final button =
        isGradient && variant == AppButtonVariant.filled && !isDisabled
        ? DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: _buildButton(effectiveTextColor),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: effectiveButtonColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: effectiveBorderColor != null
                  ? Border.all(color: effectiveBorderColor, width: borderWidth)
                  : null,
            ),
            child: _buildButton(effectiveTextColor),
          );

    if (compact) {
      return IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: button,
        ),
      );
    }

    return BoxSizer(
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      safeArea: safeArea,
      child: button,
    );
  }

  Color _resolveButtonColor({
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isDisabled,
  }) {
    if (variant != AppButtonVariant.filled) return Colors.transparent;
    if (isDisabled) return colorScheme.surfaceContainerHighest;

    final color = btnColor;
    if (color == null || color == AppColors.ink) {
      return colorScheme.primary;
    }
    if (isDark &&
        (color == AppColors.white ||
            color == AppColors.line ||
            color == AppColors.grey)) {
      return colorScheme.surfaceContainerHighest;
    }
    return color;
  }

  Color _resolveTextColor({
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isDisabled,
    required Color effectiveButtonColor,
  }) {
    if (isDisabled) return colorScheme.onSurfaceVariant;

    final color = textColor;
    if (color == null) {
      return switch (variant) {
        AppButtonVariant.filled => colorScheme.onPrimary,
        AppButtonVariant.outlined => colorScheme.onSurface,
        AppButtonVariant.text => colorScheme.primary,
      };
    }

    if (!isDark) return color;

    final usesPrimaryFill =
        variant == AppButtonVariant.filled &&
        effectiveButtonColor == colorScheme.primary;
    if (color == AppColors.ink) {
      return usesPrimaryFill ? colorScheme.onPrimary : colorScheme.onSurface;
    }
    if (color == AppColors.paper || color == AppColors.white) {
      return usesPrimaryFill ? colorScheme.onPrimary : colorScheme.onSurface;
    }
    if (color == AppColors.signal &&
        variant == AppButtonVariant.filled &&
        (btnColor == null || btnColor == AppColors.ink)) {
      return colorScheme.onPrimary;
    }
    if (color == AppColors.muted) return colorScheme.onSurfaceVariant;
    return color;
  }

  Color? _resolveBorderColor({
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isDisabled,
  }) {
    final color = borderColor;
    if (color != null) {
      if (isDisabled) return colorScheme.outlineVariant;
      if (isDark && color == AppColors.line) return colorScheme.outline;
      return color;
    }
    if (variant != AppButtonVariant.outlined) return null;
    return isDisabled ? colorScheme.outlineVariant : colorScheme.outline;
  }

  Widget _buildButton(Color effectiveTextColor) {
    final content = isLoading
        ? SpinKitThreeBounce(color: effectiveTextColor, size: 16)
        : child != null
        ? IconTheme(
            data: IconThemeData(color: effectiveTextColor),
            child: child!,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: effectiveTextColor, size: 18),
                  child: icon!,
                ),
                const SizedBox(width: 8),
              ],
              AppText(
                text: text,
                type: AppTextType.labelLarge,
                textAlign: TextAlign.center,
                fontSize: fontSize.textSize,
                fontWeight: FontWeight.w600,
                fontFamily: "Mulish",
                color: effectiveTextColor,
              ),
            ],
          );

    return CupertinoButton(
      onPressed: isLoading ? null : onPressed,
      padding: compact && child == null
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
          : EdgeInsets.zero,
      alignment: Alignment.center,
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.transparent,
      pressedOpacity: .78,
      child: Center(
        widthFactor: compact ? 1 : null,
        heightFactor: compact ? 1 : null,
        child: content,
      ),
    );
  }
}
