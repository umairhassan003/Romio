import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WebTheme {
  WebTheme._();

  static const String _fontFamily = 'Inter';

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.adminContentBg,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryBurgundy,
      secondary: AppColors.primaryBurgundyLight,
      surface: Colors.white,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimary,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBurgundy,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBurgundy,
        side: const BorderSide(color: AppColors.borderLight),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBurgundy,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBurgundy, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceLight,
      labelStyle: const TextStyle(color: AppColors.primaryBurgundy, fontFamily: _fontFamily),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.adminTableHeaderBg),
      headingTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      dataTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A0F16),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryBurgundy,
      secondary: AppColors.primaryBurgundyLight,
      surface: const Color(0xFF2D1B29),
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSurface: const Color(0xFFE8D5DE),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2D1B29),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF4A3245)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D1B29),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE8D5DE),
      ),
      iconTheme: IconThemeData(color: Color(0xFFE8D5DE)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBurgundy,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBurgundyLight,
        side: const BorderSide(color: Color(0xFF4A3245)),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D1B29),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4A3245)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4A3245)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBurgundyLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF3D2A38),
      labelStyle: const TextStyle(color: AppColors.primaryBurgundyLight, fontFamily: _fontFamily),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(const Color(0xFF3D2A38)),
      headingTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Color(0xFFE8D5DE),
      ),
      dataTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        color: Color(0xFFE8D5DE),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF4A3245),
      thickness: 1,
    ),
  );
}
