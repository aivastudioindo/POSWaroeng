import 'package:sqflite/sqflite.dart';

import '../../../core/format/tanggal.dart';
import '../domain/cart.dart';
import '../domain/sale.dart';

/// Repository penjualan: posting transaksi kasir dalam SATU transaction sqflite.
///
/// Menyimpan `sales` + `sale_items` + `stock_movements` dan meng-update
/// `products.stock_base` secara atomik (rencana teknis §2.3). Bila ada error,
/// seluruhnya rollback.
class SaleRepository {
  SaleRepository(this._db);

  final Database _db;

  /// Posting penjualan tunai dari [cart] dengan uang dibayar [paidAmount].
  ///
  /// Mengembalikan [Sale] final berisi id, invoice, total, dan kembalian.
  Future<Sale> postSale({
    required Cart cart,
    required int paidAmount,
    String paymentMethod = 'TUNAI',
    String? note,
  }) async {
    if (cart.isEmpty) {
      throw ArgumentError('Keranjang kosong, tidak bisa memposting penjualan.');
    }

    final now = TanggalId.nowEpochMillis();
    final total = cart.total;
    final change = paidAmount - total;
    if (change < 0) {
      throw ArgumentError('Uang dibayar kurang dari total.');
    }

    return _db.transaction<Sale>((txn) async {
      final invoiceNo = _generateInvoiceNo(now);
      final saleMap = <String, Object?>{
        'invoice_no': invoiceNo,
        'sale_date': now,
        'subtotal': cart.subtotal,
        'discount': cart.discount,
        'total': total,
        'paid_amount': paidAmount,
        'change_amount': change,
        'payment_method': paymentMethod,
        'note': note,
        'created_at': now,
      };
      final saleId = await txn.insert('sales', saleMap);

      for (final item in cart.items) {
        final qtyBase = item.qtyBase;
        await txn.insert(
          'sale_items',
          item.copyWith(saleId: saleId).toMap()..remove('id'),
        );

        // Saldo stok sesudah mutasi (audit) — dibaca sebelum update.
        final rows = await txn.query(
          'products',
          columns: ['stock_base'],
          where: 'id = ?',
          whereArgs: [item.productId],
          limit: 1,
        );
        final currentStock = rows.isEmpty
            ? 0.0
            : (rows.first['stock_base'] as num).toDouble();
        final balanceAfter = currentStock - qtyBase;

        await txn.insert('stock_movements', {
          'product_id': item.productId,
          'qty_base': -qtyBase,
          'balance_base': balanceAfter,
          'type': 'SALE',
          'ref_table': 'sales',
          'ref_id': saleId,
          'created_at': now,
        });

        await txn.rawUpdate(
          'UPDATE products SET stock_base = stock_base - ?, updated_at = ? WHERE id = ?',
          [qtyBase, now, item.productId],
        );
      }

      return Sale(
        id: saleId,
        invoiceNo: invoiceNo,
        saleDate: now,
        subtotal: cart.subtotal,
        discount: cart.discount,
        total: total,
        paidAmount: paidAmount,
        changeAmount: change,
        paymentMethod: paymentMethod,
        note: note,
        createdAt: now,
        items: cart.items,
      );
    });
  }

  /// Nomor struk sederhana berbasis waktu: `INV-yyyyMMdd-HHmmss-mmm`.
  static String _generateInvoiceNo(int epochMillis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true);
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    return 'INV-${dt.year}${two(dt.month)}${two(dt.day)}-'
        '${two(dt.hour)}${two(dt.minute)}${two(dt.second)}-'
        '${three(dt.millisecond)}';
  }

  /// Agregasi ringkas penjualan pada rentang [fromMillis, toMillis).
  Future<({int revenue, int count})> summaryInRange(
    int fromMillis,
    int toMillis,
  ) async {
    final rows = await _db.rawQuery(
      'SELECT COALESCE(SUM(total),0) AS revenue, COUNT(*) AS cnt '
      'FROM sales WHERE sale_date >= ? AND sale_date < ?',
      [fromMillis, toMillis],
    );
    final row = rows.first;
    return (
      revenue: (row['revenue'] as num).toInt(),
      count: (row['cnt'] as num).toInt(),
    );
  }
}
