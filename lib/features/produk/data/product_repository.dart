import 'package:sqflite/sqflite.dart';

import '../../../core/format/tanggal.dart';
import '../domain/product.dart';
import '../domain/product_unit.dart';

/// Repository produk: CRUD produk + satuan (PCS dasar) di SQLite.
class ProductRepository {
  ProductRepository(this._db);

  final DatabaseExecutor _db;

  /// Ambil produk aktif, opsional filter pencarian prefix (indexed).
  Future<List<Product>> fetchProducts({String? query, int? limit}) async {
    final where = StringBuffer('deleted_at IS NULL AND is_active = 1');
    final args = <Object?>[];
    if (query != null && query.trim().isNotEmpty) {
      where.write(' AND (name LIKE ? OR code LIKE ?)');
      final prefix = '${query.trim()}%';
      args
        ..add(prefix)
        ..add(prefix);
    }
    final rows = await _db.query(
      'products',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE ASC',
      limit: limit,
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> findById(int id) async {
    final rows = await _db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<List<ProductUnit>> fetchUnits(int productId) async {
    final rows = await _db.query(
      'product_units',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'sort_order ASC, conversion_to_base ASC',
    );
    return rows.map(ProductUnit.fromMap).toList();
  }

  /// Simpan produk baru beserta satuan dasar (PCS). Mengembalikan id produk.
  ///
  /// Membungkus insert produk + satuan dasar dalam satu transaksi bila [_db]
  /// adalah [Database]; bila sudah di dalam transaksi (Transaction) tulisan
  /// tetap atomik terhadap transaksi induk.
  Future<int> createProduct(Product product, {List<ProductUnit>? units}) async {
    Future<int> run(DatabaseExecutor txn) async {
      final now = TanggalId.nowEpochMillis();
      final id = await txn.insert(
        'products',
        product.copyWith(createdAt: now, updatedAt: now).toMap()..remove('id'),
      );
      final unitList =
          units ??
          [
            ProductUnit(
              unitName: product.baseUnit,
              conversionToBase: 1,
              sellPrice: product.sellPriceBase,
              costPrice: product.costPriceBase,
              isBase: true,
            ),
          ];
      for (final u in unitList) {
        await txn.insert(
          'product_units',
          u.copyWith(productId: id).toMap()..remove('id'),
        );
      }
      return id;
    }

    final db = _db;
    if (db is Database) {
      return db.transaction(run);
    }
    return run(db);
  }

  /// Perbarui produk (dan opsional satuan). Menghapus & menulis ulang satuan
  /// bila [units] diberikan.
  Future<void> updateProduct(
    Product product, {
    List<ProductUnit>? units,
  }) async {
    Future<void> run(DatabaseExecutor txn) async {
      final now = TanggalId.nowEpochMillis();
      await txn.update(
        'products',
        product.copyWith(updatedAt: now).toMap()..remove('created_at'),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      if (units != null) {
        await txn.delete(
          'product_units',
          where: 'product_id = ?',
          whereArgs: [product.id],
        );
        for (final u in units) {
          await txn.insert(
            'product_units',
            u.copyWith(productId: product.id).toMap()..remove('id'),
          );
        }
      }
    }

    final db = _db;
    if (db is Database) {
      await db.transaction(run);
    } else {
      await run(db);
    }
  }

  /// Soft-delete produk agar riwayat tetap valid.
  Future<void> softDelete(int id) async {
    final now = TanggalId.nowEpochMillis();
    await _db.update(
      'products',
      {'deleted_at': now, 'is_active': 0, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
