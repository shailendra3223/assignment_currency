import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor    = Color(0xFF6C63FF);
  static const Color secondaryColor  = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFF0F0E17);
  static const Color surfaceColor    = Color(0xFF1A1A2E);
  static const Color cardColor       = Color(0xFF16213E);
  static const Color accentColor     = Color(0xFFFF6584);
  static const Color successColor    = Color(0xFF4CAF50);
  static const Color errorColor      = Color(0xFFCF6679);
  static const Color textPrimary     = Color(0xFFF5F5F5);
  static const Color textSecondary   = Color(0xFFB0B0C3);
  static const Color dividerColor    = Color(0xFF2D2D44);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3B37D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      surfaceTint: Colors.transparent,
    ),
    scaffoldBackgroundColor: backgroundColor,
    canvasColor: backgroundColor,
    cardColor: cardColor,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textPrimary),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textSecondary),
      labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: dividerColor, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: GoogleFonts.poppins(color: textSecondary),
      hintStyle: GoogleFonts.poppins(color: textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      indicatorColor: primaryColor.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.poppins(fontSize: 12, color: textSecondary),
      ),
    ),
  );
}
