import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF094CB2);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF3366CC);
  static const onPrimaryContainer = Color(0xFFE7EBFF);
  static const primaryFixed = Color(0xFFD9E2FF);
  static const primaryFixedDim = Color(0xFFB1C5FF);
  static const inversePrimary = Color(0xFFB1C5FF);

  // Secondary
  static const secondary = Color(0xFF5A5F63);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFDFE3E8);
  static const onSecondaryContainer = Color(0xFF606569);
  static const secondaryFixed = Color(0xFFDFE3E8);
  static const secondaryFixedDim = Color(0xFFC2C7CC);

  // Tertiary
  static const tertiary = Color(0xFF6D5E00);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFBFAB49);
  static const onTertiaryContainer = Color(0xFF4A3F00);
  static const tertiaryFixed = Color(0xFFF9E37A);
  static const tertiaryFixedDim = Color(0xFFDCC661);
  static const onTertiaryFixed = Color(0xFF211B00);
  static const onTertiaryFixedVariant = Color(0xFF524600);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Surface
  static const background = Color(0xFFFAF9FA);
  static const onBackground = Color(0xFF1B1C1D);
  static const surface = Color(0xFFFAF9FA);
  static const onSurface = Color(0xFF1B1C1D);
  static const surfaceDim = Color(0xFFDBDADB);
  static const surfaceBright = Color(0xFFFAF9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F3F4);
  static const surfaceContainer = Color(0xFFEFEDEE);
  static const surfaceContainerHigh = Color(0xFFE9E8E9);
  static const surfaceContainerHighest = Color(0xFFE3E2E3);
  static const surfaceVariant = Color(0xFFE3E2E3);
  static const onSurfaceVariant = Color(0xFF434653);
  static const inverseSurface = Color(0xFF303031);
  static const inverseOnSurface = Color(0xFFF2F0F1);

  // Outline
  static const outline = Color(0xFF737784);
  static const outlineVariant = Color(0xFFC3C6D5);
  static const surfaceTint = Color(0xFF2259BF);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.withOpacity(0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest.withOpacity(0.92),
        indicatorColor: AppColors.primary.withOpacity(0.08),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.publicSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: selected ? AppColors.primary : AppColors.outline,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.outline,
            size: 24,
          );
        }),
        elevation: 0,
        height: 72,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.outline,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.publicSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.inverseOnSurface,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.notoSerif(
          fontSize: 57, fontWeight: FontWeight.w900, color: AppColors.onSurface),
      displayMedium: GoogleFonts.notoSerif(
          fontSize: 45, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      displaySmall: GoogleFonts.notoSerif(
          fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineLarge: GoogleFonts.notoSerif(
          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineMedium: GoogleFonts.notoSerif(
          fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineSmall: GoogleFonts.notoSerif(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      titleLarge: GoogleFonts.notoSerif(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleSmall: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
      labelLarge: GoogleFonts.publicSans(
          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      labelMedium: GoogleFonts.publicSans(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      labelSmall: GoogleFonts.publicSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.onSurfaceVariant),
    );
  }
}
