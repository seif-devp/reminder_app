import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  bool isDarkMode() => _loadThemeFromBox();

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  void switchTheme() {
    bool isDark = !_loadThemeFromBox();
    _saveThemeToBox(isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

