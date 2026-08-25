import 'package:sqflite/sqflite.dart';

/// Kunci pengaturan yang dikenal (tabel key-value `settings`).
class SettingKeys {
  SettingKeys._();
  static const storeName = 'store_name';
  static const storeAddress = 'store_address';
  static const storePhone = 'store_phone';
  static const receiptHeader = 'receipt_header';
  static const receiptFooter = 'receipt_footer';
  static const paperSize = 'paper_size'; // '58' | '80'
  static const printerMac = 'printer_mac';
  static const printerName = 'printer_name';
}

/// Repository pengaturan aplikasi berbasis tabel key-value `settings`.
class SettingsRepository {
  SettingsRepository(this._db);

  final DatabaseExecutor _db;

  Future<Map<String, String>> fetchAll() async {
    final rows = await _db.query('settings');
    return {
      for (final r in rows) r['key'] as String: (r['value'] as String?) ?? '',
    };
  }

  Future<String?> get(String key) async {
    final rows = await _db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> set(String key, String value) async {
    await _db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> setAll(Map<String, String> values) async {
    for (final entry in values.entries) {
      await set(entry.key, entry.value);
    }
  }
}
