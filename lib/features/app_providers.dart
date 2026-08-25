import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/db_providers.dart';
import '../../core/printing/printer_service.dart';
import '../kasir/data/sale_repository.dart';
import '../produk/data/product_repository.dart';
import 'data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(databaseProvider));
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository(ref.watch(databaseProvider));
});

final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterService();
});

/// Semua pengaturan (key-value) sebagai map reaktif.
final settingsProvider = FutureProvider<Map<String, String>>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchAll();
});
