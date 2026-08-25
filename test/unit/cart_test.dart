import 'package:flutter_test/flutter_test.dart';
import 'package:poswaroeng/features/kasir/domain/cart.dart';
import 'package:poswaroeng/features/kasir/domain/sale.dart';

void main() {
  SaleItem item({
    int productId = 1,
    String unit = 'PCS',
    double conversion = 1,
    double qty = 1,
    int price = 1000,
  }) {
    return SaleItem(
      productId: productId,
      productName: 'Produk $productId',
      unitName: unit,
      conversionToBase: conversion,
      qty: qty,
      sellPrice: price,
    );
  }

  group('SaleItem', () {
    test('qtyBase = qty * conversionToBase', () {
      expect(item(qty: 2, conversion: 144).qtyBase, 288);
    });

    test('subtotal = price * qty (dibulatkan)', () {
      expect(item(qty: 3, price: 1500).subtotal, 4500);
    });
  });

  group('Cart total & kembalian', () {
    test('subtotal menjumlahkan semua item', () {
      final cart = const Cart()
          .addItem(item(productId: 1, qty: 2, price: 1000))
          .addItem(item(productId: 2, qty: 1, price: 5000));
      expect(cart.subtotal, 7000);
      expect(cart.total, 7000);
    });

    test('diskon mengurangi total, tidak pernah negatif', () {
      final cart = const Cart(discount: 10000)
          .addItem(item(qty: 1, price: 5000));
      expect(cart.total, 0);
    });

    test('changeFor menghitung kembalian', () {
      final cart = const Cart().addItem(item(qty: 1, price: 7000));
      expect(cart.changeFor(10000), 3000);
      expect(cart.changeFor(5000), -2000);
    });

    test('addItem menggabungkan produk+satuan sama', () {
      final cart = const Cart()
          .addItem(item(productId: 1, unit: 'PCS', qty: 1))
          .addItem(item(productId: 1, unit: 'PCS', qty: 2));
      expect(cart.itemCount, 1);
      expect(cart.items.first.qty, 3);
    });

    test('addItem satuan berbeda tetap terpisah', () {
      final cart = const Cart()
          .addItem(item(productId: 1, unit: 'PCS', qty: 1))
          .addItem(item(productId: 1, unit: 'BOX', conversion: 12, qty: 1));
      expect(cart.itemCount, 2);
    });

    test('updateQtyAt 0 menghapus item', () {
      final cart = const Cart().addItem(item(qty: 1));
      expect(cart.updateQtyAt(0, 0).isEmpty, isTrue);
    });
  });
}
