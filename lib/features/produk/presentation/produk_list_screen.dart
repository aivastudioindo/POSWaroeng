import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/surface_card.dart';
import 'product_providers.dart';

/// Daftar produk dengan pencarian prefix + CRUD dasar.
class ProdukListScreen extends ConsumerWidget {
  const ProdukListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    final shapes = context.appShapes;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Produk'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(Routes.produkForm);
          ref.invalidate(productListProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(shapes.pagePadding),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari produk (nama / kode)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  ref.read(productSearchProvider.notifier).update(v),
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat produk: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada produk.\nTekan Tambah untuk membuat produk.',
                      textAlign: TextAlign.center,
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.appColors.textMuted,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: shapes.pagePadding),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: shapes.gap),
                      child: SurfaceCard(
                        onTap: () async {
                          await context.push(Routes.produkForm, extra: p.id);
                          ref.invalidate(productListProvider);
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: context.texts.titleSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Stok: ${p.stockBase.toStringAsFixed(0)} ${p.baseUnit}',
                                    style: context.texts.labelSmall?.copyWith(
                                      color: p.isOutOfStock
                                          ? context.appColors.danger
                                          : p.isLowStock
                                          ? context.appColors.warning
                                          : context.appColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Rupiah.format(p.sellPriceBase),
                              style: context.texts.titleSmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
