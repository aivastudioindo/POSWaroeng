import 'package:sqflite/sqflite.dart';

/// Migrasi skema inkremental POSWaroeng.
///
/// Aturan (rencana teknis §2.4):
/// - Setiap kenaikan versi = satu entri di [migrations].
/// - JANGAN pernah mengubah migrasi yang sudah dirilis; selalu tambah versi baru.
/// - SQLite `ALTER TABLE` terbatas (ADD COLUMN / RENAME); untuk perubahan
///   kompleks pakai pola create-new-table -> copy -> drop -> rename.
///
/// Contoh entri masa depan:
/// ```dart
/// 2: (db) async {
///   await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT');
/// },
/// ```
final Map<int, Future<void> Function(Database)> migrations =
    <int, Future<void> Function(Database)>{
      // v2, v3, ... ditambah di sini seiring evolusi skema.
    };

/// Menjalankan migrasi inkremental berurutan dari [oldVersion]+1 hingga
/// [newVersion].
Future<void> runMigrations(Database db, int oldVersion, int newVersion) async {
  for (var v = oldVersion + 1; v <= newVersion; v++) {
    final migrate = migrations[v];
    if (migrate != null) {
      await migrate(db);
    }
  }
}
