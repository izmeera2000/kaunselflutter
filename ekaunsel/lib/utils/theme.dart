import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Colors.red; // Primary color
  static const Color secondaryColor = Color(0xFF4A4A4A); // Muted dark gray
  static const Color tertiaryColor = Color(0xFFF5F0E6); // Soft beige

  static ThemeData mainTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Colors.white,
      surface: Colors.white,
      onPrimary: Colors.black,       // 👈 Text on primary (e.g., button text)
      onSecondary: Colors.black,     // 👈 Text on secondary color
      onSurface: Colors.black,       // 👈 Text on surfaces
      onBackground: Colors.black,    // 👈 General background text
      onError: Colors.white,
      error: Colors.red[700]!,
    ),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    iconTheme: IconThemeData(color: primaryColor),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
      titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Colors.black),
      labelMedium: TextStyle(color: Colors.black),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusColor: primaryColor,
      border: Config.outlinedBorder,
      focusedBorder: Config.focusBorder,
      errorBorder: Config.errorBorder,
      enabledBorder: Config.outlinedBorder,
      floatingLabelStyle: TextStyle(color: primaryColor),
      prefixIconColor: Colors.black38,
    ),
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      unselectedItemColor: Colors.grey.shade700,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
