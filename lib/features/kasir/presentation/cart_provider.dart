import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart.dart';
import '../domain/sale.dart';

/// Notifier keranjang belanja kasir (sync, screen-scoped).
class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() => const Cart();

  void addItem(SaleItem item) => state = state.addItem(item);

  void updateQtyAt(int index, double qty) =>
      state = state.updateQtyAt(index, qty);

  void removeAt(int index) => state = state.removeAt(index);

  void setDiscount(int discount) => state = state.copyWith(discount: discount);

  void clear() => state = const Cart();
}

final cartProvider = NotifierProvider<CartNotifier, Cart>(CartNotifier.new);
