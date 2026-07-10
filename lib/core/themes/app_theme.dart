import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

ThemeData cdaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CdaColors.vertForet,
      primary: CdaColors.vertForet,
      secondary: CdaColors.jaune,
      error: CdaColors.rouge,
      surface: CdaColors.creme,
    ),
    scaffoldBackgroundColor: CdaColors.creme,
  );

  return base.copyWith(
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      headlineSmall: GoogleFonts.fredoka(
          fontWeight: FontWeight.w600, color: CdaColors.encre),
      titleLarge: GoogleFonts.fredoka(
          fontWeight: FontWeight.w600, color: CdaColors.encre),
      titleMedium: GoogleFonts.fredoka(
          fontWeight: FontWeight.w500, color: CdaColors.vertFonce),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CdaColors.vertForet,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CdaColors.vertForet,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      selectedColor: CdaColors.vertForet,
      backgroundColor: Colors.white,
      side: const BorderSide(color: CdaColors.ligne),
      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: CdaColors.ligne),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: CdaColors.vertForet,
      unselectedItemColor: CdaColors.gris,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
