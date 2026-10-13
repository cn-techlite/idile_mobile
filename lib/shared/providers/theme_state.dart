import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    loadTheme();
    return ThemeMode.system;
  }

  Future<void> toggleTheme() =>
      setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await (await SharedPreferences.getInstance()).setString(
      'appearance',
      mode.name,
    );
  }

  Future<void> loadTheme() async {
    final value = (await SharedPreferences.getInstance()).getString(
      'appearance',
    );
    state = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
