import 'package:flutter/material.dart';

import '../theme/theme_x.dart';

/// Kartu dengan gradien biru (hero/tombol). Bayangan biru mengambang.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final shapes = context.appShapes;
    final radius = borderRadius ?? shapes.heroRadius;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.appColors.heroGradient,
        borderRadius: radius,
        boxShadow: shapes.elevatedBlueShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(shapes.gapLarge),
            child: child,
          ),
        ),
      ),
    );
  }
}
