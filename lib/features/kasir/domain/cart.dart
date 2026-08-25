import 'package:flutter/foundation.dart';

import 'sale.dart';

/// State keranjang belanja kasir (immutable). Menghitung subtotal & total.
@immutable
class Cart {
  const Cart({this.items = const [], this.discount = 0});

  final List<SaleItem> items;
  final int discount;

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  int get total {
    final t = subtotal - discount;
    return t < 0 ? 0 : t;
  }

  int get itemCount => items.length;

  int get totalQty => items.fold(0, (sum, item) => sum + item.qty.round());

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// Kembalian untuk uang dibayar [paid]. Negatif => kurang.
  int changeFor(int paid) => paid - total;

  Cart copyWith({List<SaleItem>? items, int? discount}) {
    return Cart(
      items: items ?? this.items,
      discount: discount ?? this.discount,
    );
  }

  /// Tambah item; bila produk+satuan sama sudah ada, gabungkan qty.
  Cart addItem(SaleItem item) {
    final index = items.indexWhere(
      (i) => i.productId == item.productId && i.unitName == item.unitName,
    );
    final next = [...items];
    if (index >= 0) {
      final existing = next[index];
      next[index] = existing.copyWith(qty: existing.qty + item.qty);
    } else {
      next.add(item);
    }
    return copyWith(items: next);
  }

  Cart updateQtyAt(int index, double qty) {
    if (index < 0 || index >= items.length) return this;
    final next = [...items];
    if (qty <= 0) {
      next.removeAt(index);
    } else {
      next[index] = next[index].copyWith(qty: qty);
    }
    return copyWith(items: next);
  }

  Cart removeAt(int index) {
    if (index < 0 || index >= items.length) return this;
    final next = [...items]..removeAt(index);
    return copyWith(items: next);
  }

  Cart clear() => const Cart();
}
