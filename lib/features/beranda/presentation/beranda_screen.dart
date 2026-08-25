import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/gradient_card.dart';
import '../../../core/widgets/surface_card.dart';
import '../../app_providers.dart';
import 'beranda_providers.dart';

/// Beranda (dashboard) sesuai spec UI §3.
class BerandaScreen extends ConsumerWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shapes = context.appShapes;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: const Text('POSWAROENG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () {
              ref.invalidate(todayReportProvider);
              ref.invalidate(settingsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayReportProvider);
          ref.invalidate(settingsProvider);
          await ref.read(todayReportProvider.future);
        },
        child: ListView(
          padding: EdgeInsets.all(shapes.pagePadding),
          children: [
            const _HeroReportCard(),
            SizedBox(height: shapes.gap),
            const _StoreIdentityCard(),
            SizedBox(height: shapes.gapLarge),
            Text('Menu Utama', style: context.texts.titleMedium),
            SizedBox(height: shapes.gap),
            const _MenuGrid(),
            SizedBox(height: shapes.gapLarge),
            const _TransaksiButton(),
            SizedBox(height: shapes.gap),
          ],
        ),
      ),
    );
  }
}

class _HeroReportCard extends ConsumerWidget {
  const _HeroReportCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(todayReportProvider);
    const onGradient = Colors.white;
    return GradientCard(
      child: report.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        error: (e, _) => SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'Gagal memuat laporan',
              style: context.texts.bodyMedium?.copyWith(color: onGradient),
            ),
          ),
        ),
        data: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Laporan Hari Ini',
                  style: context.texts.titleSmall?.copyWith(color: onGradient),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: context.appShapes.chipRadius,
                  ),
                  child: Text(
                    'KASIR AKTIF',
                    style: context.texts.labelSmall?.copyWith(
                      color: onGradient,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Pendapatan',
              style: context.texts.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 2),
            Text(
              Rupiah.compact(r.revenue),
              style: context.texts.headlineMedium?.copyWith(
                color: onGradient,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeroPill(
                  label: '${r.transactionCount} transaksi',
                  color: onGradient,
                ),
                _HeroPill(
                  label: '${r.lowStockCount} produk menipis',
                  color: onGradient,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: context.appShapes.chipRadius,
      ),
      child: Text(
        label,
        style: context.texts.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _StoreIdentityCard extends ConsumerWidget {
  const _StoreIdentityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeName = ref.watch(storeNameProvider);
    return SurfaceCard(
      onTap: () => context.push(Routes.pengaturan),
      padding: EdgeInsets.all(context.appShapes.gap),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: context.colors.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.storefront_rounded,
              color: context.colors.primary,
            ),
          ),
          SizedBox(width: context.appShapes.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(storeName, style: context.texts.titleMedium),
                Text(
                  'Kasir & Manajemen Toko',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.appColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: context.appColors.textMuted),
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final items = <_MenuItem>[
      _MenuItem(
        'Produk',
        'Kelola produk & satuan',
        Icons.inventory_2_rounded,
        appColors.menuBlue,
        Routes.produk,
      ),
      _MenuItem(
        'Stok',
        'Pantau persediaan',
        Icons.warehouse_rounded,
        appColors.menuIndigo,
        Routes.stok,
      ),
      _MenuItem(
        'Barang Masuk',
        'Pembelian & hutang',
        Icons.local_shipping_rounded,
        appColors.menuPurple,
        Routes.barangMasuk,
      ),
      _MenuItem(
        'Pengeluaran',
        'Catat biaya',
        Icons.payments_rounded,
        appColors.menuTeal,
        Routes.pengeluaran,
      ),
      _MenuItem(
        'Laporan',
        'Rekap penjualan',
        Icons.bar_chart_rounded,
        appColors.menuAmber,
        Routes.laporan,
      ),
      _MenuItem(
        'Riwayat',
        'Transaksi lampau',
        Icons.history_rounded,
        appColors.menuRose,
        Routes.riwayat,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, i) => _MenuTile(item: items[i]),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.label, this.subtitle, this.icon, this.color, this.route);
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});
  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: () => context.push(item.route),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color, item.color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: context.texts.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            style: context.texts.labelSmall?.copyWith(
              color: context.appColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TransaksiButton extends StatelessWidget {
  const _TransaksiButton();

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: () => context.push(Routes.kasir),
      borderRadius: context.appShapes.buttonRadius,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.point_of_sale_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            'TRANSAKSI',
            style: context.texts.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
