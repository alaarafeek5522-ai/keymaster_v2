import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgDark       = Color(0xFF0A0A0F);
  static const Color bgCard       = Color(0xFF14141F);
  static const Color bgElevated   = Color(0xFF1E1E2E);
  static const Color gold         = Color(0xFFD4AF37);
  static const Color goldDim      = Color(0xFFB8860B);
  static const Color goldGlow     = Color(0xFFFFD700);
  static const Color cyan         = Color(0xFF00E5FF);
  static const Color cyanGlow     = Color(0xFF00B8D4);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color textPrimary  = Color(0xFFF0F0F5);
  static const Color textSecondary= Color(0xFF8A8A9A);
  static const Color textMuted    = Color(0xFF5A5A6A);
  static const Color success      = Color(0xFF00E676);
  static const Color error        = Color(0xFFFF1744);
  static const Color warning      = Color(0xFFFF9100);
  static const Color purple       = Color(0xFF7C4DFF);

  static BoxDecoration glowCard({Color? glowColor}) => BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: (glowColor ?? gold).withOpacity(0.15),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: (glowColor ?? gold).withOpacity(0.1),
        blurRadius: 24,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: cyan,
      surface: bgCard,
      background: bgDark,
      error: error,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.w900),
      titleLarge: GoogleFonts.cairo(color: textPrimary, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.cairo(color: textPrimary),
      bodyMedium: GoogleFonts.cairo(color: textSecondary),
      labelLarge: GoogleFonts.cairo(color: textSecondary, fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 8,
        shadowColor: gold.withOpacity(0.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: GoogleFonts.cairo(color: textMuted),
    ),
  );
}
