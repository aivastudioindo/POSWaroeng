import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/surface_card.dart';
import '../../produk/domain/product.dart';
import '../../produk/presentation/product_providers.dart';
import '../domain/sale.dart';
import 'bayar_sheet.dart';
import 'cart_provider.dart';

/// Layar kasir: katalog (daftar/grid) + keranjang menempel di bawah.
class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});

  @override
  ConsumerState<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> {
  bool _gridView = false;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);
    final cart = ref.watch(cartProvider);
    final shapes = context.appShapes;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('KASIR'),
        actions: [
          IconButton(
            tooltip: _gridView ? 'Tampilan daftar' : 'Tampilan grid',
            icon: Icon(
              _gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _gridView = !_gridView),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(shapes.pagePadding),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari produk',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  ref.read(productSearchProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada produk.',
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.appColors.textMuted,
                      ),
                    ),
                  );
                }
                return _gridView
                    ? _CatalogGrid(products: list)
                    : _CatalogList(products: list);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CartBar(
              itemCount: cart.itemCount,
              total: cart.total,
              onPay: () => showBayarSheet(context, ref),
            ),
    );
  }
}

void _addToCart(WidgetRef ref, Product p) {
  ref
      .read(cartProvider.notifier)
      .addItem(
        SaleItem(
          productId: p.id!,
          productName: p.name,
          unitName: p.baseUnit,
          conversionToBase: 1,
          qty: 1,
          sellPrice: p.sellPriceBase,
          costPrice: p.costPriceBase,
        ),
      );
}

class _CatalogList extends ConsumerWidget {
  const _CatalogList({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shapes = context.appShapes;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: shapes.pagePadding),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return Padding(
          padding: EdgeInsets.only(bottom: shapes.gap),
          child: SurfaceCard(
            onTap: () => _addToCart(ref, p),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: context.texts.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        'Sisa ${p.stockBase.toStringAsFixed(0)} ${p.baseUnit}',
                        style: context.texts.labelSmall?.copyWith(
                          color: context.appColors.textMuted,
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
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _addToCart(ref, p),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CatalogGrid extends ConsumerWidget {
  const _CatalogGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shapes = context.appShapes;
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: shapes.pagePadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return SurfaceCard(
          onTap: () => _addToCart(ref, p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: context.colors.primary,
                size: 32,
              ),
              Text(
                p.name,
                style: context.texts.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                Rupiah.format(p.sellPriceBase),
                style: context.texts.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.itemCount,
    required this.total,
    required this.onPay,
  });

  final int itemCount;
  final int total;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.appShapes.pagePadding),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: context.appColors.heroGradient,
            borderRadius: context.appShapes.buttonRadius,
            boxShadow: context.appShapes.elevatedBlueShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPay,
              borderRadius: context.appShapes.buttonRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$itemCount item',
                          style: context.texts.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          Rupiah.format(total),
                          style: context.texts.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'BAYAR',
                      style: context.texts.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
