import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_x.dart';

/// Layar placeholder untuk menu yang belum aktif (jelas "segera hadir").
class SegeraHadirScreen extends StatelessWidget {
  const SegeraHadirScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.appShapes.gapLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 64,
                color: appColors.textMuted,
              ),
              SizedBox(height: context.appShapes.gap),
              Text('Segera hadir', style: context.texts.titleLarge),
              SizedBox(height: context.appShapes.gap / 2),
              Text(
                'Fitur "$title" sedang disiapkan dan akan tersedia pada '
                'pembaruan berikutnya.',
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium?.copyWith(
                  color: appColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
