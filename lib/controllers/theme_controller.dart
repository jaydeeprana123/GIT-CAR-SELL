import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../db/db_helper.dart';

class ThemeController extends GetxController {
  final RxString currentThemeKey = 'teal_dark'.obs;
  final DbHelper _dbHelper = DbHelper();

  ThemeController({required String initialTheme}) {
    currentThemeKey.value = initialTheme;
  }

  ThemeData get currentThemeData {
    return getThemeData(currentThemeKey.value);
  }

  ThemeMode get currentThemeMode {
    if (currentThemeKey.value.endsWith('_light')) {
      return ThemeMode.light;
    }
    return ThemeMode.dark;
  }

  void changeTheme(String themeKey) async {
    currentThemeKey.value = themeKey;
    await _dbHelper.saveSetting('themeKey', themeKey);
    Get.changeTheme(getThemeData(themeKey));
    Get.changeThemeMode(themeKey.endsWith('_light') ? ThemeMode.light : ThemeMode.dark);
  }

  ThemeData getThemeData(String key) {
    switch (key) {
      case 'blue_dark':
        return _buildDarkTheme(
          primary: const Color(0xFF3B82F6), // Blue
          secondary: const Color(0xFF6366F1), // Indigo
          background: const Color(0xFF030712), // Deep Blue Grey
          surface: const Color(0xFF111827),
          divider: const Color(0xFF1F2937),
        );
      case 'amber_dark':
        return _buildDarkTheme(
          primary: const Color(0xFFF59E0B), // Amber
          secondary: const Color(0xFFD97706), // Gold/Amber Dark
          background: const Color(0xFF0C0A09), // Stone
          surface: const Color(0xFF1C1917),
          divider: const Color(0xFF292524),
        );
      case 'purple_dark':
        return _buildDarkTheme(
          primary: const Color(0xFF8B5CF6), // Purple
          secondary: const Color(0xFFD946EF), // Fuchsia
          background: const Color(0xFF0B0415), // Deep Purple Grey
          surface: const Color(0xFF160D27),
          divider: const Color(0xFF26183B),
        );
      case 'teal_light':
        return _buildLightTheme(
          primary: const Color(0xFF0D9488), // Teal
          secondary: const Color(0xFF0891B2), // Cyan
          background: const Color(0xFFF8FAFC), // Slate 50
          surface: const Color(0xFFFFFFFF),
          divider: const Color(0xFFE2E8F0),
        );
      case 'mono_light':
        return _buildLightTheme(
          primary: const Color(0xFF000000), // Black
          secondary: const Color(0xFF475569), // Slate 600
          background: const Color(0xFFFFFFFF), // White
          surface: const Color(0xFFF8FAFC), // Slate 50
          divider: const Color(0xFFE2E8F0), // Slate 200
        );
      case 'teal_dark':
      default:
        return _buildDarkTheme(
          primary: const Color(0xFF0D9488), // Teal
          secondary: const Color(0xFF0891B2), // Cyan
          background: const Color(0xFF0F172A), // Slate 900
          surface: const Color(0xFF1E293B),    // Slate 800
          divider: const Color(0xFF334155),
        );
    }
  }

  ThemeData _buildDarkTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color divider,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: divider,
        disabledColor: surface,
        selectedColor: primary.withOpacity(0.2),
        secondarySelectedColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: const TextStyle(fontSize: 12),
        secondaryLabelStyle: const TextStyle(fontSize: 12, color: Colors.white),
        brightness: Brightness.dark,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color divider,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0.5,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: divider,
        disabledColor: surface,
        selectedColor: primary.withOpacity(0.2),
        secondarySelectedColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
        secondaryLabelStyle: const TextStyle(fontSize: 12, color: Colors.white),
        brightness: Brightness.light,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
