import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262E);
  static const Color accent = Color(0xFF2BD576);
  static const Color gain = Color(0xFF2BD576);
  static const Color loss = Color(0xFFFF5C5C);
  static const Color textPrimary = Color(0xFFF0F3F6);
  static const Color textSecondary = Color(0xFF8B949E);

  /// Stable colors for allocation charts, keyed by account type.
  static const List<Color> allocationColors = [
    Color(0xFF2BD576),
    Color(0xFF58A6FF),
    Color(0xFFD2A8FF),
    Color(0xFFFFA657),
    Color(0xFFF778BA),
    Color(0xFF79C0FF),
  ];

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
        error: loss,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12, color: textSecondary),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Color(0xFF06250F),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
