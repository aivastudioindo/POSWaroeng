import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/beranda/presentation/beranda_screen.dart';
import '../features/kasir/presentation/kasir_screen.dart';
import '../features/pengaturan/presentation/pengaturan_screen.dart';
import '../features/placeholder/segera_hadir_screen.dart';
import '../features/produk/presentation/produk_form_screen.dart';
import '../features/produk/presentation/produk_list_screen.dart';

/// Konstanta path rute terpusat.
class Routes {
  Routes._();
  static const beranda = '/';
  static const kasir = '/kasir';
  static const produk = '/produk';
  static const produkForm = '/produk/form';
  static const pengaturan = '/pengaturan';
  static const stok = '/stok';
  static const barangMasuk = '/barang-masuk';
  static const pengeluaran = '/pengeluaran';
  static const laporan = '/laporan';
  static const riwayat = '/riwayat';
}

/// Router aplikasi (GoRouter). Didefinisikan di top-level.
final appRouter = GoRouter(
  initialLocation: Routes.beranda,
  routes: [
    GoRoute(
      path: Routes.beranda,
      builder: (context, state) => const BerandaScreen(),
    ),
    GoRoute(
      path: Routes.kasir,
      builder: (context, state) => const KasirScreen(),
    ),
    GoRoute(
      path: Routes.produk,
      builder: (context, state) => const ProdukListScreen(),
    ),
    GoRoute(
      path: Routes.produkForm,
      builder: (context, state) =>
          ProdukFormScreen(productId: state.extra as int?),
    ),
    GoRoute(
      path: Routes.pengaturan,
      builder: (context, state) => const PengaturanScreen(),
    ),
    // Menu yang belum aktif — placeholder "segera hadir" yang jelas.
    GoRoute(
      path: Routes.stok,
      builder: (context, state) => const SegeraHadirScreen(title: 'Stok'),
    ),
    GoRoute(
      path: Routes.barangMasuk,
      builder: (context, state) =>
          const SegeraHadirScreen(title: 'Barang Masuk'),
    ),
    GoRoute(
      path: Routes.pengeluaran,
      builder: (context, state) =>
          const SegeraHadirScreen(title: 'Pengeluaran'),
    ),
    GoRoute(
      path: Routes.laporan,
      builder: (context, state) => const SegeraHadirScreen(title: 'Laporan'),
    ),
    GoRoute(
      path: Routes.riwayat,
      builder: (context, state) => const SegeraHadirScreen(title: 'Riwayat'),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
  ),
);
