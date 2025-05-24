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
      background: tertiaryColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.grey[900]!,
      onBackground: Colors.grey[900]!,
      onError: Colors.white,
      error: Colors.red[700]!,
    ),
    cardColor: tertiaryColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    iconTheme: IconThemeData(color: primaryColor),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey[900], fontSize: 16),
      bodyMedium: TextStyle(color: Colors.grey[600], fontSize: 14),
      titleMedium: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
    scaffoldBackgroundColor: tertiaryColor,
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

