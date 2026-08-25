import 'package:flutter/material.dart';

/// Token warna kustom POSWaroeng di luar `ColorScheme` Material 3.
///
/// Sumber tunggal untuk gradien biru, warna positif (uang masuk), peringatan,
/// dan warna ikon menu. NOL warna hardcode di widget — semua ambil dari sini
/// via `Theme.of(context).extension<AppColors>()!`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.gradientStart,
    required this.gradientEnd,
    required this.positive,
    required this.warning,
    required this.danger,
    required this.textMuted,
    required this.hairline,
    required this.menuBlue,
    required this.menuIndigo,
    required this.menuPurple,
    required this.menuTeal,
    required this.menuAmber,
    required this.menuRose,
  });

  /// Ujung terang gradien biru (135deg start).
  final Color gradientStart;

  /// Ujung gelap gradien biru (135deg end).
  final Color gradientEnd;

  /// Angka positif / uang masuk (kembalian, profit naik).
  final Color positive;

  /// Peringatan (stok menipis).
  final Color warning;

  /// Bahaya (stok habis, hapus, titik notifikasi).
  final Color danger;

  /// Teks redup (subjudul, keterangan).
  final Color textMuted;

  /// Garis/pembatas halus.
  final Color hairline;

  final Color menuBlue;
  final Color menuIndigo;
  final Color menuPurple;
  final Color menuTeal;
  final Color menuAmber;
  final Color menuRose;

  /// Gradien hero & tombol utama (135deg).
  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  @override
  AppColors copyWith({
    Color? gradientStart,
    Color? gradientEnd,
    Color? positive,
    Color? warning,
    Color? danger,
    Color? textMuted,
    Color? hairline,
    Color? menuBlue,
    Color? menuIndigo,
    Color? menuPurple,
    Color? menuTeal,
    Color? menuAmber,
    Color? menuRose,
  }) {
    return AppColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      textMuted: textMuted ?? this.textMuted,
      hairline: hairline ?? this.hairline,
      menuBlue: menuBlue ?? this.menuBlue,
      menuIndigo: menuIndigo ?? this.menuIndigo,
      menuPurple: menuPurple ?? this.menuPurple,
      menuTeal: menuTeal ?? this.menuTeal,
      menuAmber: menuAmber ?? this.menuAmber,
      menuRose: menuRose ?? this.menuRose,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      menuBlue: Color.lerp(menuBlue, other.menuBlue, t)!,
      menuIndigo: Color.lerp(menuIndigo, other.menuIndigo, t)!,
      menuPurple: Color.lerp(menuPurple, other.menuPurple, t)!,
      menuTeal: Color.lerp(menuTeal, other.menuTeal, t)!,
      menuAmber: Color.lerp(menuAmber, other.menuAmber, t)!,
      menuRose: Color.lerp(menuRose, other.menuRose, t)!,
    );
  }

  /// Token untuk tema terang (palet BIRU MODERN dari spec UI §1).
  static const AppColors light = AppColors(
    gradientStart: Color(0xFF3B82F6),
    gradientEnd: Color(0xFF1E40AF),
    positive: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    textMuted: Color(0xFF64748B),
    hairline: Color(0xFFE7ECF3),
    menuBlue: Color(0xFF2563EB),
    menuIndigo: Color(0xFF4F46E5),
    menuPurple: Color(0xFF7C3AED),
    menuTeal: Color(0xFF0D9488),
    menuAmber: Color(0xFFF59E0B),
    menuRose: Color(0xFFE11D48),
  );

  /// Token untuk tema gelap (mengikuti sistem HP).
  static const AppColors dark = AppColors(
    gradientStart: Color(0xFF3B82F6),
    gradientEnd: Color(0xFF1E3A8A),
    positive: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    textMuted: Color(0xFF94A3B8),
    hairline: Color(0xFF1E293B),
    menuBlue: Color(0xFF3B82F6),
    menuIndigo: Color(0xFF6366F1),
    menuPurple: Color(0xFF8B5CF6),
    menuTeal: Color(0xFF14B8A6),
    menuAmber: Color(0xFFFBBF24),
    menuRose: Color(0xFFFB7185),
  );
}
