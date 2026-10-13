import 'package:flutter/material.dart';

/// Model class for Size Configurations
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late TextScaler _textScaler;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    _textScaler = _mediaQueryData.textScaler;
  }

  /// Returns height as percentage of screen height.
  static double height(double percentage, {bool safeArea = false}) {
    double height = screenHeight;
    if (safeArea) {
      final padding = _mediaQueryData.padding;
      height -= (padding.top + padding.bottom);
    }
    return (height / 100) * percentage;
  }

  /// Returns width as percentage of screen width.
  static double width(double percentage, {bool safeArea = false}) {
    double width = screenWidth;
    if (safeArea) {
      final padding = _mediaQueryData.padding;
      width -= (padding.left + padding.right);
    }
    return (width / 100) * percentage;
  }

  /// Scales font size based on device width and text scaling settings.
  static double text(double fontSize) {
    double minFontSize = screenWidth < 350 ? 10.0 : 12.0;
    double maxFontSize = screenWidth > 600 ? 46.0 : 44.0;
    double baseSize =
        ((fontSize * screenWidth) / 375); // 375 = reference iPhone width

    // Clamp to prevent extreme sizes
    double clampedFontSize = baseSize.clamp(minFontSize, maxFontSize);
    return _textScaler.scale(clampedFontSize);
  }

  /// Returns responsive image size based on width percentage.
  static double image(double imageSize) {
    return imageSize * (screenWidth / 100);
  }
}

extension SizeHelpers on num {
  double get heightAdjusted => SizeConfig.height(toDouble());
  double get widthAdjusted => SizeConfig.width(toDouble());
  double get heightSafeAdjusted =>
      SizeConfig.height(toDouble(), safeArea: true);
  double get widthSafeAdjusted => SizeConfig.width(toDouble(), safeArea: true);
  double get textSize => SizeConfig.text(toDouble());
  double get imageSize => SizeConfig.image(toDouble());
}

class BoxSizer extends StatelessWidget {
  final double? widthPercent;
  final double? heightPercent;
  final bool safeArea;
  final Widget child;

  const BoxSizer({
    super.key,
    this.widthPercent,
    this.heightPercent,
    this.safeArea = false,
    required this.child,
  });

  double _getWidth() {
    double width = SizeConfig.screenWidth;
    if (safeArea) {
      final padding = SizeConfig._mediaQueryData.padding;
      width -= (padding.left + padding.right);
    }
    return widthPercent != null
        ? (width * (widthPercent! / 100))
        : double.infinity;
  }

  double _getHeight() {
    double height = SizeConfig.screenHeight;
    if (safeArea) {
      final padding = SizeConfig._mediaQueryData.padding;
      height -= (padding.top + padding.bottom);
    }
    return heightPercent != null
        ? (height * (heightPercent! / 100))
        : double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final requestedWidth = _getWidth();
        final width = constraints.hasBoundedWidth
            ? requestedWidth.clamp(0.0, constraints.maxWidth).toDouble()
            : requestedWidth;
        return SizedBox(width: width, height: _getHeight(), child: child);
      },
    );
  }
}

/// Adds vertical spacing as a percentage of screen height.
Widget addVerticalSpacing(double heightPercent, {bool safeArea = false}) {
  return SizedBox(height: SizeConfig.height(heightPercent, safeArea: safeArea));
}

/// Adds horizontal spacing as a percentage of screen width.
Widget addHorizontalSpacing(double widthPercent, {bool safeArea = false}) {
  return SizedBox(width: SizeConfig.width(widthPercent, safeArea: safeArea));
}
