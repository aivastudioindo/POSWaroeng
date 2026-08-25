/// Helper konversi satuan multi-unit POSWaroeng.
///
/// Prinsip (lihat rencana teknis §2.1):
/// - Stok fisik SELALU disimpan dalam satuan dasar (PCS) di `products.stock_base`.
/// - Setiap satuan (PCS/BOX/DUS) punya faktor `conversionToBase` = berapa PCS
///   per 1 satuan tersebut (PCS=1, BOX=12, DUS=144).
/// - `qtyBase = qty * conversionToBase`.
library;

/// Menghitung jumlah dalam satuan dasar (PCS) dari [qty] pada satuan dengan
/// faktor konversi [conversionToBase].
///
/// Contoh: 2 DUS dengan faktor 144 => 288 PCS.
double toBaseQty(double qty, double conversionToBase) {
  if (conversionToBase <= 0) {
    throw ArgumentError.value(
      conversionToBase,
      'conversionToBase',
      'Faktor konversi harus > 0',
    );
  }
  return qty * conversionToBase;
}

/// Menghitung jumlah dalam satuan tertentu dari [qtyBase] (PCS) dengan faktor
/// [conversionToBase]. Kebalikan dari [toBaseQty].
double fromBaseQty(double qtyBase, double conversionToBase) {
  if (conversionToBase <= 0) {
    throw ArgumentError.value(
      conversionToBase,
      'conversionToBase',
      'Faktor konversi harus > 0',
    );
  }
  return qtyBase / conversionToBase;
}

/// Menghitung faktor konversi ke satuan dasar dari konversi bertingkat.
///
/// Contoh: 1 DUS = 12 BOX, 1 BOX = 12 PCS => [12, 12] => 144.
/// Daftar kosong => 1 (satuan dasar itu sendiri).
double conversionFromTiers(List<num> tiers) {
  var result = 1.0;
  for (final t in tiers) {
    if (t <= 0) {
      throw ArgumentError.value(t, 'tiers', 'Setiap tingkat harus > 0');
    }
    result *= t.toDouble();
  }
  return result;
}

/// Memecah [qtyBase] (PCS) menjadi rincian per satuan, dari satuan terbesar
/// ke terkecil, untuk keterangan UI ("2 DUS 3 PCS").
///
/// [unitFactors] adalah pasangan (nama satuan, faktor ke PCS). Diurutkan
/// menurun otomatis. Mengembalikan daftar (nama, jumlah bulat) tanpa entri nol.
List<({String unit, int qty})> breakdownBaseQty(
  double qtyBase,
  List<({String unit, double factor})> unitFactors,
) {
  final sorted = [...unitFactors]..sort((a, b) => b.factor.compareTo(a.factor));
  var remaining = qtyBase.round();
  final result = <({String unit, int qty})>[];
  for (final u in sorted) {
    final f = u.factor.round();
    if (f <= 0) continue;
    final count = remaining ~/ f;
    if (count > 0) {
      result.add((unit: u.unit, qty: count));
      remaining -= count * f;
    }
  }
  return result;
}
