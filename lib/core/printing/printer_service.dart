import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../features/kasir/domain/sale.dart';
import 'receipt_builder.dart';

/// Info printer paired yang dapat dipilih pengguna.
class PairedPrinter {
  const PairedPrinter({required this.name, required this.mac});
  final String name;
  final String mac;
}

/// Hasil percobaan cetak.
enum PrintOutcome { success, notConnected, noPermission, error }

/// Layanan printer thermal Bluetooth (adapter tunggal di balik
/// `print_bluetooth_thermal` + `esc_pos_utils_plus`).
///
/// Rencana teknis §4.1: bungkus package di satu tempat agar mudah diganti.
/// Andalkan perangkat yang SUDAH paired via Setelan HP (tanpa izin lokasi).
class PrinterService {
  PrinterService({ReceiptBuilder? builder})
    : _builder = builder ?? const ReceiptBuilder();

  final ReceiptBuilder _builder;

  /// Izin BLUETOOTH_CONNECT (hanya diperlukan Android 12+).
  Future<bool> hasPermission() =>
      PrintBluetoothThermal.isPermissionBluetoothGranted;

  Future<bool> isBluetoothOn() => PrintBluetoothThermal.bluetoothEnabled;

  Future<bool> get isConnected => PrintBluetoothThermal.connectionStatus;

  /// Daftar printer yang sudah dipasangkan di Setelan HP.
  Future<List<PairedPrinter>> pairedPrinters() async {
    final list = await PrintBluetoothThermal.pairedBluetooths;
    return list
        .map((b) => PairedPrinter(name: b.name, mac: b.macAdress))
        .toList();
  }

  Future<bool> connect(String mac) =>
      PrintBluetoothThermal.connect(macPrinterAddress: mac);

  Future<bool> disconnect() => PrintBluetoothThermal.disconnect;

  /// Cetak struk [sale]. Mengembalikan status ringkas untuk UI menampilkan
  /// fallback pratinjau bila gagal.
  Future<PrintOutcome> printReceipt(
    Sale sale,
    StoreReceiptInfo store, {
    String? mac,
  }) async {
    try {
      if (!await hasPermission()) return PrintOutcome.noPermission;

      var connected = await isConnected;
      if (!connected && mac != null) {
        connected = await connect(mac);
      }
      if (!connected) return PrintOutcome.notConnected;

      final profile = await CapabilityProfile.load();
      final bytes = await _builder.build(sale, store, profile);
      final ok = await PrintBluetoothThermal.writeBytes(bytes);
      return ok ? PrintOutcome.success : PrintOutcome.error;
    } catch (_) {
      return PrintOutcome.error;
    }
  }
}
