import 'package:flutter/foundation.dart';

/// Baris item dalam keranjang / penjualan. Snapshot harga & faktor satuan.
@immutable
class SaleItem {
  const SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.conversionToBase,
    required this.qty,
    required this.sellPrice,
    this.costPrice = 0,
  });

  final int? id;
  final int? saleId;
  final int productId;
  final String productName;
  final String unitName;
  final double conversionToBase;
  final double qty;
  final int sellPrice;
  final int costPrice;

  /// Jumlah dalam satuan dasar (PCS) untuk mutasi stok.
  double get qtyBase => qty * conversionToBase;

  /// Subtotal baris (rupiah bulat).
  int get subtotal => (sellPrice * qty).round();

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    String? unitName,
    double? conversionToBase,
    double? qty,
    int? sellPrice,
    int? costPrice,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitName: unitName ?? this.unitName,
      conversionToBase: conversionToBase ?? this.conversionToBase,
      qty: qty ?? this.qty,
      sellPrice: sellPrice ?? this.sellPrice,
      costPrice: costPrice ?? this.costPrice,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'unit_name': unitName,
      'conversion_to_base': conversionToBase,
      'qty': qty,
      'qty_base': qtyBase,
      'sell_price': sellPrice,
      'cost_price': costPrice,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromMap(Map<String, Object?> map) {
    return SaleItem(
      id: map['id'] as int?,
      saleId: map['sale_id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      unitName: map['unit_name'] as String,
      conversionToBase: (map['conversion_to_base'] as num).toDouble(),
      qty: (map['qty'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toInt(),
      costPrice: (map['cost_price'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Transaksi penjualan (header). Uang dalam `int` rupiah.
@immutable
class Sale {
  const Sale({
    this.id,
    this.invoiceNo,
    required this.saleDate,
    required this.subtotal,
    this.discount = 0,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
    this.paymentMethod = 'TUNAI',
    this.note,
    required this.createdAt,
    this.items = const [],
  });

  final int? id;
  final String? invoiceNo;
  final int saleDate;
  final int subtotal;
  final int discount;
  final int total;
  final int paidAmount;
  final int changeAmount;
  final String paymentMethod;
  final String? note;
  final int createdAt;
  final List<SaleItem> items;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'invoice_no': invoiceNo,
      'sale_date': saleDate,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
      'payment_method': paymentMethod,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory Sale.fromMap(Map<String, Object?> map) {
    return Sale(
      id: map['id'] as int?,
      invoiceNo: map['invoice_no'] as String?,
      saleDate: map['sale_date'] as int,
      subtotal: (map['subtotal'] as num).toInt(),
      discount: (map['discount'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num).toInt(),
      paidAmount: (map['paid_amount'] as num).toInt(),
      changeAmount: (map['change_amount'] as num).toInt(),
      paymentMethod: map['payment_method'] as String? ?? 'TUNAI',
      note: map['note'] as String?,
      createdAt: map['created_at'] as int,
    );
  }
}
