import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/printing/printer_service.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/surface_card.dart';
import '../../app_providers.dart';
import '../data/settings_repository.dart';

/// Pengaturan toko dasar + pilih printer paired (disimpan di tabel settings).
class PengaturanScreen extends ConsumerStatefulWidget {
  const PengaturanScreen({super.key});

  @override
  ConsumerState<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends ConsumerState<PengaturanScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _initialized = false;
  bool _saving = false;
  String _paperSize = '58';
  String? _printerMac;
  String? _printerName;
  List<PairedPrinter> _printers = const [];
  bool _loadingPrinters = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await ref.read(settingsRepositoryProvider).fetchAll();
    _nameCtrl.text = settings[SettingKeys.storeName] ?? '';
    _addressCtrl.text = settings[SettingKeys.storeAddress] ?? '';
    _phoneCtrl.text = settings[SettingKeys.storePhone] ?? '';
    _paperSize = settings[SettingKeys.paperSize] ?? '58';
    _printerMac = settings[SettingKeys.printerMac];
    _printerName = settings[SettingKeys.printerName];
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrinters() async {
    setState(() => _loadingPrinters = true);
    final printer = ref.read(printerServiceProvider);
    try {
      if (!await printer.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin Bluetooth diperlukan untuk memindai printer.',
              ),
            ),
          );
        }
      }
      final list = await printer.pairedPrinters();
      if (mounted) setState(() => _printers = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat printer: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingPrinters = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setAll({
      SettingKeys.storeName: _nameCtrl.text.trim(),
      SettingKeys.storeAddress: _addressCtrl.text.trim(),
      SettingKeys.storePhone: _phoneCtrl.text.trim(),
      SettingKeys.paperSize: _paperSize,
      if (_printerMac != null) SettingKeys.printerMac: _printerMac!,
      if (_printerName != null) SettingKeys.printerName: _printerName!,
    });
    ref.invalidate(settingsProvider);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pengaturan tersimpan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shapes = context.appShapes;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Pengaturan Toko'),
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(shapes.pagePadding),
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama toko'),
                ),
                SizedBox(height: shapes.gap),
                TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  maxLines: 2,
                ),
                SizedBox(height: shapes.gap),
                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Telepon'),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: shapes.gapLarge),
                Text('Ukuran kertas struk', style: context.texts.titleSmall),
                SizedBox(height: shapes.gap / 2),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '58', label: Text('58mm')),
                    ButtonSegment(value: '80', label: Text('80mm')),
                  ],
                  selected: {_paperSize},
                  onSelectionChanged: (s) =>
                      setState(() => _paperSize = s.first),
                ),
                SizedBox(height: shapes.gapLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Printer', style: context.texts.titleSmall),
                    TextButton.icon(
                      onPressed: _loadingPrinters ? null : _loadPrinters,
                      icon: const Icon(Icons.bluetooth_searching, size: 18),
                      label: const Text('Muat paired'),
                    ),
                  ],
                ),
                if (_printerName != null)
                  SurfaceCard(
                    child: Row(
                      children: [
                        const Icon(Icons.print_rounded),
                        SizedBox(width: shapes.gap),
                        Expanded(
                          child: Text(
                            'Terpilih: $_printerName',
                            style: context.texts.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_loadingPrinters)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ..._printers.map(
                  (p) => Padding(
                    padding: EdgeInsets.only(top: shapes.gap),
                    child: SurfaceCard(
                      onTap: () => setState(() {
                        _printerMac = p.mac;
                        _printerName = p.name;
                      }),
                      child: Row(
                        children: [
                          Icon(
                            _printerMac == p.mac
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: context.colors.primary,
                          ),
                          SizedBox(width: shapes.gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: context.texts.titleSmall),
                                Text(
                                  p.mac,
                                  style: context.texts.labelSmall?.copyWith(
                                    color: context.appColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: shapes.gapLarge),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SIMPAN'),
                ),
              ],
            ),
    );
  }
}
