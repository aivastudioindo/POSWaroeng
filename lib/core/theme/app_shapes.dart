import 'package:flutter/material.dart';

/// Token bentuk & spasi POSWaroeng (radius, bayangan, jarak).
///
/// Nilai dari spec UI §2. Diakses via
/// `Theme.of(context).extension<AppShapes>()!`.
@immutable
class AppShapes extends ThemeExtension<AppShapes> {
  const AppShapes({
    this.radiusCard = 16.0,
    this.radiusHero = 22.0,
    this.radiusButton = 15.0,
    this.radiusChip = 999.0,
    this.gap = 12.0,
    this.gapLarge = 20.0,
    this.pagePadding = 16.0,
  });

  final double radiusCard;
  final double radiusHero;
  final double radiusButton;
  final double radiusChip;
  final double gap;
  final double gapLarge;
  final double pagePadding;

  BorderRadius get cardRadius => BorderRadius.circular(radiusCard);
  BorderRadius get heroRadius => BorderRadius.circular(radiusHero);
  BorderRadius get buttonRadius => BorderRadius.circular(radiusButton);
  BorderRadius get chipRadius => BorderRadius.circular(radiusChip);

  /// Bayangan lembut kartu biasa (spec UI §2).
  List<BoxShadow> get cardShadow => const [
    BoxShadow(color: Color(0x0D0F172A), blurRadius: 10, offset: Offset(0, 2)),
  ];

  /// Bayangan berwarna biru untuk tombol/hero mengambang (spec UI §2).
  List<BoxShadow> get elevatedBlueShadow => const [
    BoxShadow(color: Color(0x402563EB), blurRadius: 28, offset: Offset(0, 10)),
  ];

  @override
  AppShapes copyWith({
    double? radiusCard,
    double? radiusHero,
    double? radiusButton,
    double? radiusChip,
    double? gap,
    double? gapLarge,
    double? pagePadding,
  }) {
    return AppShapes(
      radiusCard: radiusCard ?? this.radiusCard,
      radiusHero: radiusHero ?? this.radiusHero,
      radiusButton: radiusButton ?? this.radiusButton,
      radiusChip: radiusChip ?? this.radiusChip,
      gap: gap ?? this.gap,
      gapLarge: gapLarge ?? this.gapLarge,
      pagePadding: pagePadding ?? this.pagePadding,
    );
  }

  @override
  AppShapes lerp(AppShapes? other, double t) {
    if (other == null) return this;
    return AppShapes(
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t),
      radiusHero: lerpDouble(radiusHero, other.radiusHero, t),
      radiusButton: lerpDouble(radiusButton, other.radiusButton, t),
      radiusChip: lerpDouble(radiusChip, other.radiusChip, t),
      gap: lerpDouble(gap, other.gap, t),
      gapLarge: lerpDouble(gapLarge, other.gapLarge, t),
      pagePadding: lerpDouble(pagePadding, other.pagePadding, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  static const AppShapes standard = AppShapes();
}
