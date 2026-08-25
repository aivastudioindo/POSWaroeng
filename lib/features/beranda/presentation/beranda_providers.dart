import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/tanggal.dart';
import '../../app_providers.dart';

/// Ringkasan laporan hari ini untuk kartu hero beranda.
class TodayReport {
  const TodayReport({
    required this.revenue,
    required this.transactionCount,
    required this.lowStockCount,
  });

  final int revenue;
  final int transactionCount;
  final int lowStockCount;
}

/// Ambil agregasi penjualan hari ini + jumlah produk stok menipis.
final todayReportProvider = FutureProvider<TodayReport>((ref) async {
  final saleRepo = ref.watch(saleRepositoryProvider);

  final now = DateTime.now();
  final startLocal = DateTime(now.year, now.month, now.day);
  final endLocal = startLocal.add(const Duration(days: 1));
  final fromMillis = startLocal.toUtc().millisecondsSinceEpoch;
  final toMillis = endLocal.toUtc().millisecondsSinceEpoch;

  final summary = await saleRepo.summaryInRange(fromMillis, toMillis);

  final db = ref.watch(productRepositoryProvider);
  final products = await db.fetchProducts(limit: 1000);
  final lowStock = products.where((p) => p.isLowStock).length;

  return TodayReport(
    revenue: summary.revenue,
    transactionCount: summary.count,
    lowStockCount: lowStock,
  );
});

/// Nama toko dari pengaturan (default 'POSWAROENG').
final storeNameProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider).value ?? const {};
  final name = settings['store_name'];
  return (name == null || name.isEmpty) ? 'POSWAROENG' : name;
});

/// Tanggal hari ini terformat panjang (id_ID).
String todayLabel() => TanggalId.panjang(DateTime.now());
