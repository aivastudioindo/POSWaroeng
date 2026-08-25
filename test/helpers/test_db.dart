import 'package:poswaroeng/core/db/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Membuka database in-memory memakai sqflite_common_ffi untuk pengujian di
/// runner Linux (tanpa Android).
Future<AppDatabase> openTestDatabase() async {
  sqfliteFfiInit();
  final db = AppDatabase(
    factory: databaseFactoryFfi,
    overridePath: inMemoryDatabasePath,
  );
  await db.open();
  return db;
}
