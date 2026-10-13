import 'package:flutter/material.dart';

// ENUM APP TEXT TYPE
enum AppTextType {
  displayLarge,
  displayMedium,
  displaySmall,

  headlineLarge,
  headlineMedium,
  headlineSmall,

  titleLarge,
  titleMedium,
  titleSmall,

  bodyLarge,
  bodyMedium,
  bodySmall,

  labelLarge,
  labelMedium,
  labelSmall,
}

extension AppTextTypeExtension on AppTextType {
  TextStyle resolve(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (this) {
      case AppTextType.displayLarge:
        return textTheme.displayLarge!;
      case AppTextType.displayMedium:
        return textTheme.displayMedium!;
      case AppTextType.displaySmall:
        return textTheme.displaySmall!;

      case AppTextType.headlineLarge:
        return textTheme.headlineLarge!;
      case AppTextType.headlineMedium:
        return textTheme.headlineMedium!;
      case AppTextType.headlineSmall:
        return textTheme.headlineSmall!;

      case AppTextType.titleLarge:
        return textTheme.titleLarge!;
      case AppTextType.titleMedium:
        return textTheme.titleMedium!;
      case AppTextType.titleSmall:
        return textTheme.titleSmall!;

      case AppTextType.bodyLarge:
        return textTheme.bodyLarge!;
      case AppTextType.bodyMedium:
        return textTheme.bodyMedium!;
      case AppTextType.bodySmall:
        return textTheme.bodySmall!;

      case AppTextType.labelLarge:
        return textTheme.labelLarge!;
      case AppTextType.labelMedium:
        return textTheme.labelMedium!;
      case AppTextType.labelSmall:
        return textTheme.labelSmall!;
    }
  }

  /// 🔥 Custom style builder
  TextStyle style(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return resolve(context).copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }
}

class AppText extends StatelessWidget {
  final String text;
  final InlineSpan? textSpan;
  final AppTextType? type;
  final TextStyle? style;

  final Color? color;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final double? fontSize;
  final double? height;
  final String? fontFamily;
  final List<FontFeature>? fontFeatures;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final FontStyle? fontStyle;

  // Retained while older feature screens are migrated to [AppTextType].
  final bool? isBody;
  final double? linHeight;

  const AppText({
    super.key,
    required this.text,
    this.type = AppTextType.bodyMedium,
    this.style,
    this.color,
    this.textAlign,
    this.textDirection,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.locale,
    this.strutStyle,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.fontSize,
    this.height,
    this.fontFamily,
    this.fontFeatures,
    this.letterSpacing,
    this.fontWeight,
    this.decoration,
    this.fontStyle,
    this.isBody,
    this.linHeight,
  }) : textSpan = null;

  /// Compatibility constructor for feature screens that still pass a full
  /// [TextStyle]. New code should use [AppTextType] through [AppText].
  const AppText.raw(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null,
       type = null,
       color = null,
       fontSize = null,
       height = null,
       fontFamily = null,
       fontFeatures = null,
       letterSpacing = null,
       fontWeight = null,
       decoration = null,
       fontStyle = null,
       isBody = null,
       linHeight = null;

  /// Use for copy containing multiple inline styles while keeping all text
  /// rendering behind the project's shared text component.
  const AppText.rich(
    this.textSpan, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : text = '',
       type = null,
       style = null,
       color = null,
       fontSize = null,
       height = null,
       fontFamily = null,
       fontFeatures = null,
       letterSpacing = null,
       fontWeight = null,
       decoration = null,
       fontStyle = null,
       isBody = null,
       linHeight = null;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? type?.resolve(context);
    final hasOverrides =
        color != null ||
        fontSize != null ||
        height != null ||
        fontFamily != null ||
        fontFeatures != null ||
        letterSpacing != null ||
        fontWeight != null ||
        decoration != null ||
        fontStyle != null ||
        linHeight != null;
    final resolvedStyle = hasOverrides
        ? (baseStyle ?? const TextStyle()).copyWith(
            color: color ?? baseStyle?.color,
            fontSize: fontSize,
            height: height ?? linHeight,
            fontFamily: fontFamily,
            fontFeatures: fontFeatures,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight ?? baseStyle?.fontWeight,
            decoration: decoration,
            fontStyle: fontStyle,
          )
        : baseStyle;

    final span = textSpan;
    if (span != null) {
      return Text.rich(
        span,
        style: resolvedStyle,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
        textScaler: textScaler,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return Text(
      text,
      style: resolvedStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      textScaler: textScaler,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
