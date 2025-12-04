import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF1E88E5);

  // Light
  static const Color _lightBackground = Color(0xFFF6F7F8);
  static const Color _lightSurface = Colors.white;
  static const Color _lightTextPrimary = Color(0xFF1C1E21);
  static const Color _lightTextSecondary = Color(0xFF7C828A);
  static const Color _lightBorder = Color(0xFFE0E0E0);

  // Dark
  static const Color _darkBackground = Color(0xFF101922);
  static const Color _darkSurface = Color(0xFF1F2937);
  static const Color _darkTextPrimary = Colors.white;
  static const Color _darkTextSecondary = Color(0xFF9EA6AD);

  // ---------------- LIGHT THEME ----------------
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

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      foregroundColor: _lightTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),

    // NavigationBar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _lightSurface,
      indicatorColor: _primaryColor.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: _lightTextPrimary),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: _lightTextPrimary),
      ),
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _lightTextSecondary,
      showUnselectedLabels: true,
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _primaryColor),
        foregroundColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),

    // Card
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Checkbox - Radio - Switch
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(_primaryColor),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(_primaryColor),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(_primaryColor),
      trackColor: WidgetStateProperty.all(_primaryColor.withValues(alpha: 0.5)),
    ),

    // Input
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
    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: _primaryColor,
      inactiveTrackColor: _primaryColor.withValues(alpha: 0.3),
      thumbColor: _primaryColor,
      overlayColor: _primaryColor.withValues(alpha: 0.2),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // TabBar
    tabBarTheme: const TabBarThemeData(
      labelColor: _primaryColor,
      unselectedLabelColor: _lightTextSecondary,
      indicatorColor: _primaryColor,
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: _lightSurface,
      surfaceTintColor: Colors.transparent,
    ),

    // Badge
    badgeTheme: const BadgeThemeData(
      backgroundColor: _primaryColor,
      textColor: Colors.white,
    ),

    // ListTile
    listTileTheme: const ListTileThemeData(
      iconColor: _lightTextPrimary,
      textColor: _lightTextPrimary,
      tileColor: _lightSurface,
    ),
  );

  // ---------------- DARK THEME ----------------
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

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),

    // NavigationBar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _darkSurface,
      indicatorColor: _primaryColor.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: _darkTextPrimary),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: _darkTextPrimary),
      ),
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _darkTextSecondary,
      showUnselectedLabels: true,
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _primaryColor),
        foregroundColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),

    // Card
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Checkbox - Radio - Switch
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(_primaryColor),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(_primaryColor),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(_primaryColor),
      trackColor: WidgetStateProperty.all(_primaryColor.withValues(alpha: 0.5)),
    ),

    // Input
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
    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: _primaryColor,
      inactiveTrackColor: _primaryColor.withValues(alpha: 0.3),
      thumbColor: _primaryColor,
      overlayColor: _primaryColor.withValues(alpha: 0.2),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // TabBar
    tabBarTheme: const TabBarThemeData(
      labelColor: _primaryColor,
      unselectedLabelColor: _darkTextSecondary,
      indicatorColor: _primaryColor,
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
    ),

    // Badge
    badgeTheme: const BadgeThemeData(
      backgroundColor: _primaryColor,
      textColor: Colors.white,
    ),

    // ListTile
    listTileTheme: const ListTileThemeData(
      iconColor: _darkTextPrimary,
      textColor: _darkTextPrimary,
      tileColor: _darkSurface,
    ),
  );
}
