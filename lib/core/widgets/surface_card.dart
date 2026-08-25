import 'package:flutter/material.dart';

import '../theme/theme_x.dart';

/// Kartu putih standar dengan bayangan lembut & radius kartu.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shapes = context.appShapes;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: shapes.cardRadius,
        boxShadow: shapes.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: shapes.cardRadius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(shapes.gap),
            child: child,
          ),
        ),
      ),
    );
  }
}
