import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color scaffoldDark = Color(0xFF09090B);
  static const Color surfaceDark = Color(0xFF18181B);
  static const Color surfaceContainerDark = Color(0xFF27272A);
  static const Color primaryAccent = Color(0xFFEC4899);
  static const Color secondaryAccent = Color(0xFF06B6D4);
  static const Color onSurfaceDark = Color(0xFFFAFAFA);
  static const Color onSurfaceVariantDark = Color(0xFFA1A1AA);
  static const Color outlineDark = Color(0xFF3F3F46);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldDark,
      colorScheme: const ColorScheme.dark(
        surface: surfaceDark,
        primary: primaryAccent,
        secondary: secondaryAccent,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF0C0C0E),
        onSurface: onSurfaceDark,
        outline: outlineDark,
      ).copyWith(
        surfaceContainerHighest: surfaceContainerDark,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.archivo(
          textStyle: base.textTheme.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.archivo(
          textStyle: base.textTheme.headlineSmall,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.archivo(
          textStyle: base.textTheme.headlineMedium,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark.withValues(alpha: 0.72),
        foregroundColor: onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primaryAccent.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryAccent,
            );
          }
          return GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: onSurfaceVariantDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryAccent, size: 24);
          }
          return const IconThemeData(color: onSurfaceVariantDark, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme),
    );
  }
}
