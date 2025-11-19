import 'package:flutter/material.dart';

class AppTheme {
  // Bu sınıfın örneklenmesini engellemek için private constructor
  AppTheme._();

  // --- Renk Paleti ---
  // Renkleri burada değişken olarak tanımlamak, ilerde değiştirmeyi kolaylaştırır.
  static const Color _primaryColor = Color(0xFF1E88E5);

  // Light Renkleri
  static const Color _lightBackground = Color(0xFFF6F7F8);
  static const Color _lightSurface = Colors.white;
  static const Color _lightTextPrimary = Color(0xFF1C1E21);
  static const Color _lightTextSecondary = Color(0xFF7C828A);
  static const Color _lightBorder = Color(0xFFE0E0E0);

  // Dark Renkleri
  static const Color _darkBackground = Color(0xFF101922);
  static const Color _darkSurface = Color(0xFF1F2937); // Input dolgu rengi
  static const Color _darkTextPrimary = Colors.white;
  static const Color _darkTextSecondary = Color(0xFF9EA6AD);

  // --- AYDINLIK (LIGHT) TEMA ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBackground,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      secondary: _lightTextSecondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9EA6AD)),
    ),
  );

  // --- KARANLIK (DARK) TEMA ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      secondary: _darkTextSecondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFF656E77)),
    ),
  );
}
