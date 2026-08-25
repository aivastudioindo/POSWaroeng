import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';
import 'schema.dart';

/// Pengelola koneksi database POSWaroeng.
///
/// Membuka SQLite lokal, menerapkan skema v1, menjalankan migrasi, dan
/// mengaktifkan foreign keys. Dapat diuji di runner Linux via
/// `sqflite_common_ffi` dengan meng-inject [databaseFactory] & path in-memory
/// (lihat test/).
class AppDatabase {
  AppDatabase({DatabaseFactory? factory, String? overridePath})
    : _factory = factory,
      _overridePath = overridePath;

  final DatabaseFactory? _factory;
  final String? _overridePath;
  Database? _db;

  /// Instance database yang sudah terbuka. Panggil [open] lebih dulu.
  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('Database belum dibuka. Panggil open() dahulu.');
    }
    return database;
  }

  bool get isOpen => _db != null;

  /// Membuka (atau mengembalikan) koneksi database.
  Future<Database> open() async {
    if (_db != null) return _db!;

    final options = OpenDatabaseOptions(
      version: kSchemaVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    final path = await _resolvePath();

    if (_factory != null) {
      _db = await _factory.openDatabase(path, options: options);
    } else {
      _db = await openDatabase(
        path,
        version: options.version!,
        onConfigure: options.onConfigure,
        onCreate: options.onCreate,
        onUpgrade: options.onUpgrade,
      );
    }
    return _db!;
  }

  Future<String> _resolvePath() async {
    if (_overridePath != null) return _overridePath;
    final base = _factory != null
        ? await _factory.getDatabasesPath()
        : await getDatabasesPath();
    return p.join(base, 'poswaroeng.db');
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    for (final stmt in schemaV1) {
      batch.execute(stmt);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await runMigrations(db, oldVersion, newVersion);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
