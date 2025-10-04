import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryTeal = Color(0xFF00A188);
  static const Color darkGray = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF666666);
  static const Color lightTeal = Color(0xFFE0F2F1);
  
  // Urgency Colors
  static const Color urgencyRed = Color(0xFFE53E3E);
  static const Color urgencyYellow = Color(0xFFD69E2E);
  static const Color urgencyGreen = Color(0xFF38A169);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.light,
        primary: primaryTeal,
        secondary: lightTeal,
        surface: white,
        background: white,
        onPrimary: white,
        onSecondary: darkGray,
        onSurface: darkGray,
        onBackground: darkGray,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkGray,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkGray,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkGray,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGray,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGray,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: mediumGray,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: 'Avenir',
          fontSize: 16,
          color: mediumGray,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: darkGray.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightTeal,
        selectedColor: primaryTeal,
        labelStyle: const TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryTeal,
        unselectedItemColor: mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        primary: primaryTeal,
        secondary: lightTeal,
        surface: darkGray,
        background: darkGray,
        onPrimary: white,
        onSecondary: darkGray,
        onSurface: white,
        onBackground: white,
      ),
      // Similar text theme but with white text for dark mode
      textTheme: lightTheme.textTheme.apply(
        bodyColor: white,
        displayColor: white,
      ),
    );
  }
}
