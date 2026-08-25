import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:poswaroeng/core/format/rupiah.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await initializeDateFormatting('id_ID');
  });

  group('Rupiah.format', () {
    test('format penuh dengan pemisah ribuan gaya Indonesia', () {
      expect(Rupiah.format(10000), 'Rp 10.000');
      expect(Rupiah.format(1500000), 'Rp 1.500.000');
      expect(Rupiah.format(0), 'Rp 0');
    });

    test('tanpa desimal (rupiah bulat)', () {
      expect(Rupiah.format(12500), 'Rp 12.500');
    });
  });

  group('Rupiah.plain', () {
    test('tanpa simbol', () {
      expect(Rupiah.plain(10000), '10.000');
    });
  });

  group('Rupiah.compact', () {
    test('ribuan', () {
      expect(Rupiah.compact(850000), 'Rp 850rb');
      expect(Rupiah.compact(12000), 'Rp 12rb');
    });

    test('juta dengan satu desimal koma', () {
      expect(Rupiah.compact(1200000), 'Rp 1,2jt');
      expect(Rupiah.compact(1000000), 'Rp 1jt');
    });

    test('miliar', () {
      expect(Rupiah.compact(2500000000), 'Rp 2,5M');
    });

    test('di bawah 1000 penuh', () {
      expect(Rupiah.compact(500), 'Rp 500');
    });

    test('negatif', () {
      expect(Rupiah.compact(-850000), '-Rp 850rb');
    });
  });

  group('Rupiah.parse', () {
    test('mengabaikan karakter non-digit', () {
      expect(Rupiah.parse('Rp 10.000'), 10000);
      expect(Rupiah.parse('10000'), 10000);
      expect(Rupiah.parse('1.500.000'), 1500000);
    });

    test('kosong => 0', () {
      expect(Rupiah.parse(''), 0);
      expect(Rupiah.parse('abc'), 0);
    });
  });
}
