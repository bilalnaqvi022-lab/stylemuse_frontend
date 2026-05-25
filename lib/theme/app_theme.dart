import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Theme Colors
  static const Color bgLight = Color(0xFFEDE8DF);
  static const Color surfaceLight = Color(0xFFF5F0E8);
  static const Color cardLight = Color(0xFFFAF7F2);
  static const Color primaryLight = Color(0xFF7D6B7D);
  static const Color accentLight = Color(0xFFB8967A);
  static const Color textPrimaryLight = Color(0xFF3D2B3D);
  static const Color textSecondaryLight = Color(0xFF8A7A8A);
  static const Color sageGreen = Color(0xFF8A9E7B);
  static const Color dividerLight = Color(0xFFDDD5CC);
  static const Color errorColor = Color(0xFFB85C5C);

  // Dark Theme Colors
  static const Color bgDark = Color(0xFF1A1218);
  static const Color surfaceDark = Color(0xFF261E26);
  static const Color cardDark = Color(0xFF2F2530);
  static const Color primaryDark = Color(0xFFC9A84C);
  static const Color accentDark = Color(0xFFDDBB66);
  static const Color textPrimaryDark = Color(0xFFF0E8E8);
  static const Color textSecondaryDark = Color(0xFFB8A8B8);
  static const Color dividerDark = Color(0xFF3A2F3A);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryLight,
          secondary: AppColors.accentLight,
          surface: AppColors.surfaceLight,
          background: AppColors.bgLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimaryLight,
          onBackground: AppColors.textPrimaryLight,
          error: AppColors.errorColor,
        ),
        scaffoldBackgroundColor: AppColors.bgLight,
        textTheme: _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bgLight,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.cardLight,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dividerLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dividerLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.errorColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.lato(color: AppColors.textSecondaryLight),
          labelStyle: GoogleFonts.lato(color: AppColors.textSecondaryLight),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedColor: AppColors.primaryLight,
          labelStyle: GoogleFonts.lato(fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textSecondaryLight,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerLight,
          thickness: 1,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accentLight,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.primaryLight
                  : AppColors.textSecondaryLight),
          trackColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.primaryLight.withOpacity(0.3)
                  : AppColors.dividerLight),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryDark,
          secondary: AppColors.accentDark,
          surface: AppColors.surfaceDark,
          background: AppColors.bgDark,
          onPrimary: AppColors.bgDark,
          onSecondary: AppColors.bgDark,
          onSurface: AppColors.textPrimaryDark,
          onBackground: AppColors.textPrimaryDark,
          error: AppColors.errorColor,
        ),
        scaffoldBackgroundColor: AppColors.bgDark,
        textTheme: _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bgDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.errorColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.lato(color: AppColors.textSecondaryDark),
          labelStyle: GoogleFonts.lato(color: AppColors.textSecondaryDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.bgDark,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedColor: AppColors.primaryDark,
          labelStyle: GoogleFonts.lato(fontSize: 13, color: AppColors.textPrimaryDark),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.textSecondaryDark,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.bgDark,
          elevation: 4,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.primaryDark
                  : AppColors.textSecondaryDark),
          trackColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.primaryDark.withOpacity(0.3)
                  : AppColors.dividerDark),
        ),
      );

  static TextTheme _buildTextTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 48, fontWeight: FontWeight.w700, color: primary),
        displayMedium: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w600, color: primary),
        displaySmall: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: primary),
        headlineLarge: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: primary),
        headlineMedium: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w500, color: primary),
        headlineSmall: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w500, color: primary),
        titleLarge: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
        titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
        titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
        bodyLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
        bodySmall: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
        labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5),
        labelMedium: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
        labelSmall: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.5),
      );
}
