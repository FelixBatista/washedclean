import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryTeal = Color(0xFF00A188);
  static const Color darkGray = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF666666);
  static const Color lightTeal = Color(0xFFE0F2F1);
  
  // Improved contrast colors
  static const Color textSecondary = Color(0xFF555555); // Darker than mediumGray for better contrast
  static const Color textMuted = Color(0xFF777777); // Better contrast than mediumGray
  static const Color searchBackground = Color(0xFFF8F9FA); // Slightly darker than lightGray
  
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
        onPrimary: white,
        onSecondary: darkGray,
        onSurface: darkGray,
      ),
      textTheme: const TextTheme(
        // H1 Style: Cocogoose, 70/80
        displayLarge: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 70,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 80/70, // 80 line height / 70 font size
        ),
        // H2 Style: Cocogoose, 36/50
        displayMedium: TextStyle(
          fontFamily: 'Cocogoose',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: darkGray,
          height: 50/36, // 50 line height / 36 font size
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
        // Body Style: Avenir, 16/20
        bodyLarge: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGray,
          height: 20/16, // 20 line height / 16 font size
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGray,
          height: 1.6,
        ),
        // Button/Exclusions Style: Avenir, 12/20
        bodySmall: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          height: 20/12, // 20 line height / 12 font size
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
        fillColor: searchBackground,
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
          color: textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: darkGray.withValues(alpha: 0.1),
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
        unselectedItemColor: textSecondary,
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
        onPrimary: white,
        onSecondary: darkGray,
        onSurface: white,
      ),
      // Similar text theme but with white text for dark mode
      textTheme: lightTheme.textTheme.apply(
        bodyColor: white,
        displayColor: white,
      ),
    );
  }
}
