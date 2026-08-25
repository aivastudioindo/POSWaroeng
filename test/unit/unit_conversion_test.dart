import 'package:flutter_test/flutter_test.dart';
import 'package:poswaroeng/core/format/unit_conversion.dart';

void main() {
  group('toBaseQty', () {
    test('PCS (faktor 1) tetap sama', () {
      expect(toBaseQty(5, 1), 5);
    });

    test('BOX (faktor 12) dikonversi ke PCS', () {
      expect(toBaseQty(3, 12), 36);
    });

    test('DUS (faktor 144) dikonversi ke PCS', () {
      expect(toBaseQty(2, 144), 288);
    });

    test('faktor <= 0 melempar ArgumentError', () {
      expect(() => toBaseQty(1, 0), throwsArgumentError);
      expect(() => toBaseQty(1, -5), throwsArgumentError);
    });
  });

  group('fromBaseQty', () {
    test('kebalikan dari toBaseQty', () {
      expect(fromBaseQty(288, 144), 2);
      expect(fromBaseQty(36, 12), 3);
    });

    test('faktor <= 0 melempar ArgumentError', () {
      expect(() => fromBaseQty(10, 0), throwsArgumentError);
    });
  });

  group('conversionFromTiers', () {
    test('daftar kosong => 1 (satuan dasar)', () {
      expect(conversionFromTiers(const []), 1);
    });

    test('1 DUS = 12 BOX, 1 BOX = 12 PCS => 144', () {
      expect(conversionFromTiers(const [12, 12]), 144);
    });

    test('tingkat <= 0 melempar ArgumentError', () {
      expect(() => conversionFromTiers(const [12, 0]), throwsArgumentError);
    });
  });

  group('breakdownBaseQty', () {
    const units = <({String unit, double factor})>[
      (unit: 'PCS', factor: 1),
      (unit: 'BOX', factor: 12),
      (unit: 'DUS', factor: 144),
    ];

    test('291 PCS => 2 DUS, 3 PCS', () {
      final result = breakdownBaseQty(291, units);
      expect(result, [(unit: 'DUS', qty: 2), (unit: 'PCS', qty: 3)]);
    });

    test('300 PCS => 2 DUS, 1 BOX', () {
      final result = breakdownBaseQty(300, units);
      expect(result, [(unit: 'DUS', qty: 2), (unit: 'BOX', qty: 1)]);
    });

    test('0 PCS => kosong', () {
      expect(breakdownBaseQty(0, units), isEmpty);
    });
  });
}
