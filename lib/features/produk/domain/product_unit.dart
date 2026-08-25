import 'package:flutter/foundation.dart';

/// Satuan produk (PCS/BOX/DUS). Satuan dasar punya `conversionToBase = 1`.
@immutable
class ProductUnit {
  const ProductUnit({
    this.id,
    this.productId,
    required this.unitName,
    required this.conversionToBase,
    this.barcode,
    this.costPrice = 0,
    required this.sellPrice,
    this.isBase = false,
    this.sortOrder = 0,
  });

  final int? id;
  final int? productId;
  final String unitName;
  final double conversionToBase;
  final String? barcode;
  final int costPrice;
  final int sellPrice;
  final bool isBase;
  final int sortOrder;

  ProductUnit copyWith({
    int? id,
    int? productId,
    String? unitName,
    double? conversionToBase,
    String? barcode,
    int? costPrice,
    int? sellPrice,
    bool? isBase,
    int? sortOrder,
  }) {
    return ProductUnit(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      unitName: unitName ?? this.unitName,
      conversionToBase: conversionToBase ?? this.conversionToBase,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      isBase: isBase ?? this.isBase,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory ProductUnit.fromMap(Map<String, Object?> map) {
    return ProductUnit(
      id: map['id'] as int?,
      productId: map['product_id'] as int?,
      unitName: map['unit_name'] as String,
      conversionToBase: (map['conversion_to_base'] as num).toDouble(),
      barcode: map['barcode'] as String?,
      costPrice: (map['cost_price'] as num?)?.toInt() ?? 0,
      sellPrice: (map['sell_price'] as num?)?.toInt() ?? 0,
      isBase: (map['is_base'] as int? ?? 0) == 1,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      'unit_name': unitName,
      'conversion_to_base': conversionToBase,
      'barcode': barcode,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'is_base': isBase ? 1 : 0,
      'sort_order': sortOrder,
    };
  }
}
