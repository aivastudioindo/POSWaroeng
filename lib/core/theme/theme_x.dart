import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shapes.dart';

/// Akses cepat token tema kustom dari `BuildContext`.
extension AppThemeX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  AppShapes get appShapes => Theme.of(this).extension<AppShapes>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
}
