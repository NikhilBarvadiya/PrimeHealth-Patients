import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textLight = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFF1F5F9);
  static const Color successGreen = Color(0xFF10B981);
  static const Color patientVital = Color(0xFFEC4899);
  static const Color patientMedication = Color(0xFF8B5CF6);
  static const Color patientAppointment = Color(0xFF0D9488);
  static const Color patientReport = Color(0xFF3B82F6);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFCCFBF1),
      onPrimaryContainer: Color(0xFF134E4A),
      secondary: secondaryPurple,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEDE9FE),
      onSecondaryContainer: Color(0xFF4C1D95),
      tertiary: accentGreen,
      onTertiary: Colors.white,
      surface: backgroundWhite,
      onSurface: textPrimary,
      surfaceContainerHighest: backgroundLight,
      error: emergencyRed,
      onError: Colors.white,
      outline: borderColor,
      outlineVariant: dividerColor,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: textLight),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textLight),
    ),
    appBarTheme: AppBarTheme(
      elevation: 1,
      centerTitle: false,
      backgroundColor: backgroundWhite,
      foregroundColor: textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      iconTheme: const IconThemeData(color: textPrimary),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: backgroundWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.all(0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: const BorderSide(color: primaryTeal, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryTeal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: emergencyRed, width: 1),
      ),
      labelStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w500),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: textLight),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: emergencyRed),
    ),
    iconTheme: const IconThemeData(color: textPrimary, size: 24),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: backgroundWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: primaryTeal, foregroundColor: Colors.white),
  );
}
