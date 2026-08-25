import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_shapes.dart';

/// Tema terpusat POSWaroeng (Material 3, BIRU MODERN, Plus Jakarta Sans).
///
/// Satu-satunya sumber warna/tipografi/bentuk (spec UI §8). Widget WAJIB
/// mengambil nilai dari tema; tidak ada warna/ukuran hardcode.
class AppTheme {
  AppTheme._();

  /// Seed merek utama: blue-600 (spec UI §1).
  static const Color seed = Color(0xFF2563EB);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness)
        .copyWith(
          primary: isDark ? const Color(0xFF3B82F6) : seed,
          surface: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
        );

    final scaffoldBg = isDark
        ? const Color(0xFF0B1220)
        : const Color(0xFFF4F7FB);
    final onSurface = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF0F172A);

    final baseText = GoogleFonts.plusJakartaSansTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    final textTheme = _tunedTextTheme(baseText, onSurface);

    final appColors = isDark ? AppColors.dark : AppColors.light;
    const appShapes = AppShapes.standard;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[appColors, appShapes],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scaffoldBg,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: appShapes.cardRadius),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: appShapes.buttonRadius),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: appShapes.chipRadius,
          borderSide: BorderSide(color: appColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: appShapes.chipRadius,
          borderSide: BorderSide(color: appColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: appShapes.chipRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: appColors.hairline,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _tunedTextTheme(TextTheme base, Color onSurface) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: onSurface),
      bodyMedium: base.bodyMedium?.copyWith(color: onSurface),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
