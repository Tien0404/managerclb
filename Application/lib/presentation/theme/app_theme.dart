import 'package:flutter/material.dart';

class AppTheme {
  // RGB Theme Colors
  static const Color primaryColor = Color(0xFF00AA55); // Green (G in RGB)
  static const Color secondaryColor = Color(0xFF0055AA); // Blue (B in RGB)
  static const Color tertiaryColor = Color(0xFFAA5500); // Red (R in RGB)

  // Create theme data
  static ThemeData getTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        background: Colors.white,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
