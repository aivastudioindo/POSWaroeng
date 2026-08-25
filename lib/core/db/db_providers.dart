import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Provider instance [AppDatabase]. Di-override di `main()` (atau di test)
/// dengan instance yang sudah terbuka.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider harus di-override dengan AppDatabase yang terbuka.',
  );
});

/// Akses cepat ke koneksi [Database] yang sudah terbuka.
final databaseProvider = Provider<Database>((ref) {
  return ref.watch(appDatabaseProvider).db;
});
