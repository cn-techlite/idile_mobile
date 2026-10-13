import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.signal,
      brightness: brightness,
      primary: dark ? AppColors.paper : AppColors.ink,
      onPrimary: dark ? AppColors.ink : AppColors.paper,
      secondary: AppColors.signal,
      onSecondary: AppColors.ink,
      surface: dark ? AppColors.surfaceDark : AppColors.paper,
      onSurface: dark ? AppColors.paper : AppColors.ink,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF16140F) : AppColors.paper,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? AppColors.paper : AppColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: dark ? AppColors.surfaceDark : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dark ? Colors.white12 : AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.surfaceDark : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dark ? Colors.white24 : AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.signal, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? AppColors.surfaceDark : AppColors.ink,
        indicatorColor: AppColors.signal,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.signal
                : AppColors.paper,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.ink
                : AppColors.paper,
          ),
        ),
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: -.7,
        ),
        titleLarge: const TextStyle(fontWeight: FontWeight.w800),
        titleMedium: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
