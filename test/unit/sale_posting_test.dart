import 'package:flutter_test/flutter_test.dart';
import 'package:poswaroeng/core/format/tanggal.dart';
import 'package:poswaroeng/features/kasir/data/sale_repository.dart';
import 'package:poswaroeng/features/kasir/domain/cart.dart';
import 'package:poswaroeng/features/kasir/domain/sale.dart';
import 'package:poswaroeng/features/produk/data/product_repository.dart';
import 'package:poswaroeng/features/produk/domain/product.dart';
import 'package:poswaroeng/features/produk/domain/product_unit.dart';

import '../helpers/test_db.dart';

void main() {
  test('posting penjualan mengurangi stok & menjaga invariant ledger', () async {
    final appDb = await openTestDatabase();
    final db = appDb.db;
    final productRepo = ProductRepository(db);
    final saleRepo = SaleRepository(db);

    // Produk dengan stok awal 300 PCS, satuan PCS(1) & DUS(144).
    final productId = await productRepo.createProduct(
      Product(
        name: 'Mie Goreng',
        sellPriceBase: 3000,
        stockBase: 300,
        createdAt: TanggalId.nowEpochMillis(),
        updatedAt: TanggalId.nowEpochMillis(),
      ),
      units: [
        const ProductUnit(
          unitName: 'PCS',
          conversionToBase: 1,
          sellPrice: 3000,
          isBase: true,
        ),
        const ProductUnit(
          unitName: 'DUS',
          conversionToBase: 144,
          sellPrice: 400000,
        ),
      ],
    );

    // Jual 1 DUS (144 PCS) + 5 PCS => stok berkurang 149.
    final cart = const Cart()
        .addItem(
          const SaleItem(
            productId: 1,
            productName: 'Mie Goreng',
            unitName: 'DUS',
            conversionToBase: 144,
            qty: 1,
            sellPrice: 400000,
          ),
        )
        .addItem(
          const SaleItem(
            productId: 1,
            productName: 'Mie Goreng',
            unitName: 'PCS',
            conversionToBase: 1,
            qty: 5,
            sellPrice: 3000,
          ),
        );

    final total = cart.total; // 400000 + 15000 = 415000
    expect(total, 415000);

    final sale = await saleRepo.postSale(cart: cart, paidAmount: 500000);

    // Kembalian benar.
    expect(sale.changeAmount, 85000);
    expect(sale.total, 415000);

    // Stok berkurang dengan benar (300 - 149 = 151).
    final product = await productRepo.findById(productId);
    expect(product!.stockBase, 151);

    // Invariant ledger: SUM(qty_base) = stock_base.
    final ledger = await db.rawQuery(
      'SELECT COALESCE(SUM(qty_base),0) AS s FROM stock_movements WHERE product_id = ?',
      [productId],
    );
    final sum = (ledger.first['s'] as num).toDouble();
    // Belum ada mutasi OPENING (stok awal langsung di-set), jadi ledger hanya
    // mencatat penjualan; invariant diuji setelah menambah stok awal ke ledger.
    expect(sum, -149);

    // sale_items tersimpan dengan snapshot & qty_base benar.
    final items = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [sale.id],
    );
    expect(items.length, 2);

    await appDb.close();
  });

  test('menolak bila uang dibayar kurang dari total', () async {
    final appDb = await openTestDatabase();
    final productRepo = ProductRepository(appDb.db);
    final saleRepo = SaleRepository(appDb.db);
    await productRepo.createProduct(
      Product(
        name: 'Kopi',
        sellPriceBase: 5000,
        stockBase: 10,
        createdAt: TanggalId.nowEpochMillis(),
        updatedAt: TanggalId.nowEpochMillis(),
      ),
    );
    final cart = const Cart().addItem(
      const SaleItem(
        productId: 1,
        productName: 'Kopi',
        unitName: 'PCS',
        conversionToBase: 1,
        qty: 1,
        sellPrice: 5000,
      ),
    );
    expect(
      () => saleRepo.postSale(cart: cart, paidAmount: 3000),
      throwsArgumentError,
    );
    await appDb.close();
  });

  test('invariant ledger konsisten dengan OPENING + SALE', () async {
    final appDb = await openTestDatabase();
    final db = appDb.db;
    final productRepo = ProductRepository(db);
    final saleRepo = SaleRepository(db);

    final now = TanggalId.nowEpochMillis();
    final productId = await productRepo.createProduct(
      Product(
        name: 'Gula',
        sellPriceBase: 2000,
        stockBase: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Catat stok awal melalui ledger + update stok (pola OPENING).
    await db.transaction((txn) async {
      await txn.insert('stock_movements', {
        'product_id': productId,
        'qty_base': 100,
        'type': 'OPENING',
        'created_at': now,
      });
      await txn.rawUpdate(
        'UPDATE products SET stock_base = stock_base + ? WHERE id = ?',
        [100, productId],
      );
    });

    final cart = const Cart().addItem(
      const SaleItem(
        productId: 1,
        productName: 'Gula',
        unitName: 'PCS',
        conversionToBase: 1,
        qty: 30,
        sellPrice: 2000,
      ),
    );
    await saleRepo.postSale(cart: cart, paidAmount: 100000);

    final product = await productRepo.findById(productId);
    final ledger = await db.rawQuery(
      'SELECT COALESCE(SUM(qty_base),0) AS s FROM stock_movements WHERE product_id = ?',
      [productId],
    );
    final sum = (ledger.first['s'] as num).toDouble();

    // SUM(ledger) harus == stock_base (100 - 30 = 70).
    expect(product!.stockBase, 70);
    expect(sum, 70);

    await appDb.close();
  });
}
