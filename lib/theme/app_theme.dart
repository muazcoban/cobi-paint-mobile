import 'package:flutter/material.dart';

/// Theme data for different color schemes
class AppThemeData {
  final String name;
  final String icon;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color background;

  const AppThemeData({
    required this.name,
    required this.icon,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.background,
  });
}

class AppTheme {
  // Current theme (set by provider)
  static String _currentTheme = 'coral';

  static void setTheme(String themeName) {
    _currentTheme = themeName;
  }

  static String get currentTheme => _currentTheme;

  // Available themes
  static const Map<String, AppThemeData> themes = {
    'coral': AppThemeData(
      name: 'Mercan',
      icon: '🪸',
      primary: Color(0xFFFF6F61),
      primaryLight: Color(0xFFFF9A8B),
      primaryDark: Color(0xFFE85A4F),
      secondary: Color(0xFF4ECDC4),
      secondaryLight: Color(0xFF7EE8E2),
      secondaryDark: Color(0xFF36B5AD),
      background: Color(0xFFFFF8F5),
    ),
    'ocean': AppThemeData(
      name: 'Okyanus',
      icon: '🌊',
      primary: Color(0xFF5B9BD5),
      primaryLight: Color(0xFF8BC4EA),
      primaryDark: Color(0xFF3D7AB8),
      secondary: Color(0xFFFFB347),
      secondaryLight: Color(0xFFFFCF8B),
      secondaryDark: Color(0xFFE59A2F),
      background: Color(0xFFF0F8FF),
    ),
    'forest': AppThemeData(
      name: 'Orman',
      icon: '🌲',
      primary: Color(0xFF66BB6A),
      primaryLight: Color(0xFF98D99C),
      primaryDark: Color(0xFF43A047),
      secondary: Color(0xFFFFCA28),
      secondaryLight: Color(0xFFFFE082),
      secondaryDark: Color(0xFFFFA000),
      background: Color(0xFFF5FFF5),
    ),
    'sunset': AppThemeData(
      name: 'Gün Batımı',
      icon: '🌅',
      primary: Color(0xFFFF7043),
      primaryLight: Color(0xFFFF9E80),
      primaryDark: Color(0xFFE64A19),
      secondary: Color(0xFFAB47BC),
      secondaryLight: Color(0xFFCE93D8),
      secondaryDark: Color(0xFF8E24AA),
      background: Color(0xFFFFF3E0),
    ),
  };

  // Get current theme data
  static AppThemeData get current => themes[_currentTheme] ?? themes['coral']!;

  // Primary colors (dynamic based on current theme)
  static Color get primaryColor => current.primary;
  static Color get primaryLight => current.primaryLight;
  static Color get primaryDark => current.primaryDark;

  // Secondary colors
  static Color get secondaryColor => current.secondary;
  static Color get secondaryLight => current.secondaryLight;
  static Color get secondaryDark => current.secondaryDark;

  // Background colors
  static Color get backgroundColor => current.background;
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9C9EB9);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFF9800);

  // Coloring palette colors
  static const List<Color> colorPalette = [
    Color(0xFFE53935), // Red
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF9800), // Orange
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF8BC34A), // Light Green
    Color(0xFF4CAF50), // Green
    Color(0xFF009688), // Teal
    Color(0xFF00BCD4), // Cyan
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF2196F3), // Blue
    Color(0xFF3F51B5), // Indigo
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF9E9E9E), // Grey
    Color(0xFF000000), // Black
    Color(0xFFFFFFFF), // White
    Color(0xFFFCE4EC), // Pink light
    Color(0xFFE8F5E9), // Green light
    Color(0xFFE3F2FD), // Blue light
    Color(0xFFFFF8E1), // Amber light
    Color(0xFFF3E5F5), // Purple light
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
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
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
