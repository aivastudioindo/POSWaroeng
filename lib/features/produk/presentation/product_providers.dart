import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../domain/product.dart';

/// Query pencarian produk aktif (prefix, indexed). String kosong => semua.
final productSearchProvider = StateProvider<String>((ref) => '');

/// Daftar produk aktif sesuai query pencarian.
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(productSearchProvider);
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchProducts(query: query, limit: 200);
});
