import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../storage/hive_boxes.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode_v1';

  final _mode = ThemeMode.system.obs;

  Box? get _settingsBox {
    if (!Hive.isBoxOpen(HiveBoxes.settingsBox)) return null;
    return Hive.box(HiveBoxes.settingsBox);
  }

  ThemeMode get themeMode => _mode.value;

  bool get isDark => _mode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final box = _settingsBox;
    if (box == null) return;

    final raw = box.get(_themeKey);
    switch (raw) {
      case 'light':
        _mode.value = ThemeMode.light;
        break;
      case 'dark':
        _mode.value = ThemeMode.dark;
        break;
      case 'system':
      default:
        _mode.value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _mode.value = mode;
    final box = _settingsBox;
    if (box != null) {
      await box.put(
          _themeKey,
          switch (mode) {
            ThemeMode.light => 'light',
            ThemeMode.dark => 'dark',
            ThemeMode.system => 'system',
          });
    }
    update();
  }

  Future<void> toggleLightDark() async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
