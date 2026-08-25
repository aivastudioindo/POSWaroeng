import 'package:flutter_test/flutter_test.dart';
import 'package:poswaroeng/core/db/schema.dart';

import '../helpers/test_db.dart';

void main() {
  test('skema v1 membuat semua tabel yang diharapkan', () async {
    final appDb = await openTestDatabase();
    final db = appDb.db;

    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
    );
    final tables = rows.map((r) => r['name'] as String).toSet();

    const expected = {
      'categories',
      'suppliers',
      'products',
      'product_units',
      'purchases',
      'purchase_items',
      'supplier_payments',
      'sales',
      'sale_items',
      'stock_movements',
      'stock_adjustments',
      'expense_categories',
      'expenses',
      'settings',
    };

    expect(
      tables.containsAll(expected),
      isTrue,
      reason: 'Tabel hilang: ${expected.difference(tables)}',
    );

    await appDb.close();
  });

  test('versi skema sesuai kSchemaVersion', () async {
    final appDb = await openTestDatabase();
    final result = await appDb.db.rawQuery('PRAGMA user_version');
    expect(result.first.values.first, kSchemaVersion);
    await appDb.close();
  });

  test('foreign_keys aktif', () async {
    final appDb = await openTestDatabase();
    final result = await appDb.db.rawQuery('PRAGMA foreign_keys');
    expect(result.first.values.first, 1);
    await appDb.close();
  });

  test('index barcode unik parsial ada', () async {
    final appDb = await openTestDatabase();
    final rows = await appDb.db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_units_barcode'",
    );
    expect(rows, isNotEmpty);
    await appDb.close();
  });
}
