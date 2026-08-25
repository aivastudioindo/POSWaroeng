import 'package:flutter/foundation.dart';

/// Entity produk (master). Uang dalam `int` rupiah, stok dalam satuan dasar.
@immutable
class Product {
  const Product({
    this.id,
    this.code,
    required this.name,
    this.categoryId,
    this.supplierId,
    this.baseUnit = 'PCS',
    this.stockBase = 0,
    this.minStockBase = 0,
    this.costPriceBase = 0,
    required this.sellPriceBase,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final int? id;
  final String? code;
  final String name;
  final int? categoryId;
  final int? supplierId;
  final String baseUnit;
  final double stockBase;
  final double minStockBase;
  final int costPriceBase;
  final int sellPriceBase;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  bool get isLowStock => stockBase <= minStockBase && minStockBase > 0;
  bool get isOutOfStock => stockBase <= 0;

  Product copyWith({
    int? id,
    String? code,
    String? name,
    int? categoryId,
    int? supplierId,
    String? baseUnit,
    double? stockBase,
    double? minStockBase,
    int? costPriceBase,
    int? sellPriceBase,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
    int? deletedAt,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      baseUnit: baseUnit ?? this.baseUnit,
      stockBase: stockBase ?? this.stockBase,
      minStockBase: minStockBase ?? this.minStockBase,
      costPriceBase: costPriceBase ?? this.costPriceBase,
      sellPriceBase: sellPriceBase ?? this.sellPriceBase,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      code: map['code'] as String?,
      name: map['name'] as String,
      categoryId: map['category_id'] as int?,
      supplierId: map['supplier_id'] as int?,
      baseUnit: map['base_unit'] as String? ?? 'PCS',
      stockBase: (map['stock_base'] as num?)?.toDouble() ?? 0,
      minStockBase: (map['min_stock_base'] as num?)?.toDouble() ?? 0,
      costPriceBase: (map['cost_price_base'] as num?)?.toInt() ?? 0,
      sellPriceBase: (map['sell_price_base'] as num?)?.toInt() ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'base_unit': baseUnit,
      'stock_base': stockBase,
      'min_stock_base': minStockBase,
      'cost_price_base': costPriceBase,
      'sell_price_base': sellPriceBase,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}
