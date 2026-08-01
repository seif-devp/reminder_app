// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  // Gradients for light and dark mode
  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF29B6F6), Color(0xFF4DD0E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData lightTheme({String? fontFamily}) {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      primaryColor: const Color(0xFF4FC3F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4FC3F7),
        brightness: Brightness.light,
        primary: const Color(0xFF4FC3F7),
        onPrimary: Colors.white,
        background: const Color(0xFFF5F7FB),
        onBackground: Colors.black87,
      ),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      textTheme: (base.textTheme).apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
        fontFamily: fontFamily,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  static ThemeData darkTheme({String? fontFamily}) {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFF4FC3F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4FC3F7),
        brightness: Brightness.dark,
        primary: const Color(0xFF4FC3F7),
        onPrimary: Colors.black,
        background: const Color(0xFF121212),
        onBackground: Colors.white,
      ),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: (base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
        fontFamily: fontFamily,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
