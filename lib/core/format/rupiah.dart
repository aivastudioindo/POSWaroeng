import 'package:intl/intl.dart';

/// Format uang Rupiah (bulat, tanpa sen) untuk POSWaroeng.
///
/// Uang disimpan sebagai `int` rupiah (lihat rencana teknis §2.1 poin 4);
/// helper ini hanya untuk tampilan.
class Rupiah {
  Rupiah._();

  static final NumberFormat _full = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _plain = NumberFormat.decimalPattern('id_ID');

  /// Format penuh: `Rp 10.000`.
  static String format(int amount) => _full.format(amount);

  /// Format tanpa simbol: `10.000` (untuk field input).
  static String plain(int amount) => _plain.format(amount);

  /// Format ringkas untuk kartu hero: `Rp 850rb`, `Rp 1,2jt`, `Rp 12rb`.
  ///
  /// Di bawah 1000 ditampilkan penuh.
  static String compact(int amount) {
    final negative = amount < 0;
    final v = amount.abs();
    String body;
    if (v >= 1000000000) {
      body = 'Rp ${_trim(v / 1000000000)}M';
    } else if (v >= 1000000) {
      body = 'Rp ${_trim(v / 1000000)}jt';
    } else if (v >= 1000) {
      body = 'Rp ${_trim(v / 1000)}rb';
    } else {
      body = 'Rp $v';
    }
    return negative ? '-$body' : body;
  }

  static String _trim(double value) {
    // Satu desimal maksimum, koma gaya Indonesia, buang `,0`.
    final s = value.toStringAsFixed(1);
    final cleaned = s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
    return cleaned.replaceAll('.', ',');
  }

  /// Mengubah string input pengguna (`10.000`, `10000`, `Rp 10.000`) menjadi
  /// `int` rupiah. Karakter non-digit diabaikan. Kosong => 0.
  static int parse(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.parse(digits);
  }
}
