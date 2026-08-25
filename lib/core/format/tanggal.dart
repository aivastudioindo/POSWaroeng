import 'package:intl/intl.dart';

/// Format tanggal/waktu Indonesia untuk POSWaroeng.
///
/// Waktu di DB disimpan sebagai epoch millis UTC (rencana teknis §2.1 poin 5);
/// helper ini mengonversi ke lokal saat tampil.
class TanggalId {
  TanggalId._();

  static final DateFormat _tanggalPanjang = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _tanggalWaktu = DateFormat(
    'dd/MM/yyyy HH:mm',
    'id_ID',
  );
  static final DateFormat _jam = DateFormat('HH:mm', 'id_ID');

  /// `25 Agustus 2026`.
  static String panjang(DateTime dt) => _tanggalPanjang.format(dt.toLocal());

  /// `25/08/2026 14:30`.
  static String tanggalWaktu(DateTime dt) => _tanggalWaktu.format(dt.toLocal());

  /// `14:30`.
  static String jam(DateTime dt) => _jam.format(dt.toLocal());

  /// Dari epoch millis (UTC) ke DateTime lokal.
  static DateTime fromEpochMillis(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();

  /// Epoch millis (UTC) sekarang.
  static int nowEpochMillis() => DateTime.now().toUtc().millisecondsSinceEpoch;
}
