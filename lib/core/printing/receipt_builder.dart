import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../../features/kasir/domain/sale.dart';
import '../format/rupiah.dart';
import '../format/tanggal.dart';

/// Pengaturan toko untuk header/footer struk.
class StoreReceiptInfo {
  const StoreReceiptInfo({
    this.name = 'POSWAROENG',
    this.address = '',
    this.phone = '',
    this.header = '',
    this.footer = 'Terima kasih telah berbelanja',
    this.paperSize = PaperSize.mm58,
  });

  final String name;
  final String address;
  final String phone;
  final String header;
  final String footer;
  final PaperSize paperSize;
}

/// Generator baris struk ESC/POS parametrik terhadap lebar kertas (58/80mm).
class ReceiptBuilder {
  const ReceiptBuilder();

  /// Bangun byte ESC/POS untuk [sale]. [profile] biasanya
  /// `CapabilityProfile.load()`.
  Future<List<int>> build(
    Sale sale,
    StoreReceiptInfo store,
    CapabilityProfile profile,
  ) async {
    final generator = Generator(store.paperSize, profile);
    var bytes = <int>[];

    bytes += generator.text(
      store.name,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    if (store.address.isNotEmpty) {
      bytes += generator.text(
        store.address,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (store.phone.isNotEmpty) {
      bytes += generator.text(
        'Telp: ${store.phone}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (store.header.isNotEmpty) {
      bytes += generator.text(
        store.header,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: sale.invoiceNo ?? '-', width: 7),
      PosColumn(
        text: TanggalId.tanggalWaktu(TanggalId.fromEpochMillis(sale.saleDate)),
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.hr();

    for (final item in sale.items) {
      final unitSuffix = item.unitName == 'PCS' ? '' : ' ${item.unitName}';
      bytes += generator.text('${item.productName}$unitSuffix');
      bytes += generator.row([
        PosColumn(
          text: '${_qtyLabel(item.qty)} x ${Rupiah.plain(item.sellPrice)}',
          width: 7,
        ),
        PosColumn(
          text: Rupiah.plain(item.subtotal),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += _totalRow(generator, 'Subtotal', sale.subtotal);
    if (sale.discount > 0) {
      bytes += _totalRow(generator, 'Diskon', sale.discount);
    }
    bytes += _totalRow(generator, 'TOTAL', sale.total, bold: true);
    bytes += _totalRow(generator, 'Bayar', sale.paidAmount);
    bytes += _totalRow(generator, 'Kembali', sale.changeAmount);
    bytes += generator.hr();

    if (store.footer.isNotEmpty) {
      bytes += generator.text(
        store.footer,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  List<int> _totalRow(
    Generator g,
    String label,
    int amount, {
    bool bold = false,
  }) {
    return g.row([
      PosColumn(
        text: label,
        width: 7,
        styles: PosStyles(bold: bold),
      ),
      PosColumn(
        text: Rupiah.plain(amount),
        width: 5,
        styles: PosStyles(align: PosAlign.right, bold: bold),
      ),
    ]);
  }

  static String _qtyLabel(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toString();
  }
}

/// Pratinjau struk versi teks polos (fallback bila printer tak tersedia).
///
/// Lebar kolom ditentukan ukuran kertas: 58mm ~ 32 kolom, 80mm ~ 48 kolom.
class ReceiptTextPreview {
  const ReceiptTextPreview();

  String build(Sale sale, StoreReceiptInfo store) {
    final width = store.paperSize == PaperSize.mm80 ? 48 : 32;
    final b = StringBuffer();
    void center(String s) => b.writeln(_center(s, width));
    void line() => b.writeln('-' * width);
    void lr(String l, String r) => b.writeln(_lr(l, r, width));

    center(store.name);
    if (store.address.isNotEmpty) center(store.address);
    if (store.phone.isNotEmpty) center('Telp: ${store.phone}');
    if (store.header.isNotEmpty) center(store.header);
    line();
    b.writeln(sale.invoiceNo ?? '-');
    b.writeln(TanggalId.tanggalWaktu(TanggalId.fromEpochMillis(sale.saleDate)));
    line();
    for (final item in sale.items) {
      final unitSuffix = item.unitName == 'PCS' ? '' : ' ${item.unitName}';
      b.writeln('${item.productName}$unitSuffix');
      lr(
        '${ReceiptBuilder._qtyLabel(item.qty)} x ${Rupiah.plain(item.sellPrice)}',
        Rupiah.plain(item.subtotal),
      );
    }
    line();
    lr('Subtotal', Rupiah.plain(sale.subtotal));
    if (sale.discount > 0) lr('Diskon', Rupiah.plain(sale.discount));
    lr('TOTAL', Rupiah.plain(sale.total));
    lr('Bayar', Rupiah.plain(sale.paidAmount));
    lr('Kembali', Rupiah.plain(sale.changeAmount));
    line();
    if (store.footer.isNotEmpty) center(store.footer);
    return b.toString();
  }

  static String _center(String s, int width) {
    if (s.length >= width) return s;
    final pad = (width - s.length) ~/ 2;
    return '${' ' * pad}$s';
  }

  static String _lr(String l, String r, int width) {
    final space = width - l.length - r.length;
    if (space <= 0) return '$l $r';
    return '$l${' ' * space}$r';
  }
}

/// Encode string ke bytes (util pengujian bila diperlukan).
List<int> encodeUtf8(String s) => utf8.encode(s);
