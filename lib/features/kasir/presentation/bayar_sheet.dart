import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/printing/printer_service.dart';
import '../../../core/printing/receipt_builder.dart';
import '../../../core/theme/theme_x.dart';
import '../../app_providers.dart';
import '../../pengaturan/data/settings_repository.dart';
import '../domain/sale.dart';
import 'cart_provider.dart';

/// Menampilkan sheet pembayaran tunai.
Future<void> showBayarSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.appShapes.radiusHero),
      ),
    ),
    builder: (ctx) => const _BayarSheet(),
  );
}

class _BayarSheet extends ConsumerStatefulWidget {
  const _BayarSheet();

  @override
  ConsumerState<_BayarSheet> createState() => _BayarSheetState();
}

class _BayarSheetState extends ConsumerState<_BayarSheet> {
  int _paid = 0;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = cart.total;
    final change = _paid - total;
    final shapes = context.appShapes;

    return Padding(
      padding: EdgeInsets.only(
        left: shapes.pagePadding,
        right: shapes.pagePadding,
        top: shapes.gapLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + shapes.gapLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: shapes.gapLarge),
          Text('Total', style: context.texts.bodyMedium),
          Text(
            Rupiah.format(total),
            style: context.texts.headlineMedium?.copyWith(
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: shapes.gap),
          Text('Uang dibayar', style: context.texts.bodyMedium),
          Text(Rupiah.format(_paid), style: context.texts.titleLarge),
          SizedBox(height: shapes.gap / 2),
          if (_paid > 0)
            Text(
              change >= 0
                  ? 'Kembalian ${Rupiah.format(change)}'
                  : 'Kurang ${Rupiah.format(-change)}',
              style: context.texts.titleMedium?.copyWith(
                color: change >= 0
                    ? context.appColors.positive
                    : context.appColors.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          SizedBox(height: shapes.gap),
          _QuickCash(
            total: total,
            onExact: () => setState(() => _paid = total),
            onAdd: (v) => setState(() => _paid += v),
          ),
          SizedBox(height: shapes.gap),
          _Keypad(
            onDigit: (d) => setState(() {
              _paid = int.parse('$_paid$d');
            }),
            onTripleZero: () => setState(() {
              _paid = int.parse('${_paid}000');
            }),
            onBackspace: () => setState(() {
              final s = _paid.toString();
              _paid = s.length <= 1
                  ? 0
                  : int.parse(s.substring(0, s.length - 1));
            }),
            onClear: () => setState(() => _paid = 0),
          ),
          SizedBox(height: shapes.gapLarge),
          FilledButton(
            onPressed: (_paid >= total && total > 0 && !_processing)
                ? _confirm
                : null,
            child: _processing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('BAYAR & CETAK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() => _processing = true);
    final cart = ref.read(cartProvider);
    final saleRepo = ref.read(saleRepositoryProvider);
    try {
      final sale = await saleRepo.postSale(cart: cart, paidAmount: _paid);
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      Navigator.of(context).pop();
      await _printOrPreview(sale);
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memposting penjualan: $e')),
        );
      }
    }
  }

  Future<void> _printOrPreview(Sale sale) async {
    final settings = await ref.read(settingsRepositoryProvider).fetchAll();
    final store = StoreReceiptInfo(
      name: settings[SettingKeys.storeName]?.isNotEmpty == true
          ? settings[SettingKeys.storeName]!
          : 'POSWAROENG',
      address: settings[SettingKeys.storeAddress] ?? '',
      phone: settings[SettingKeys.storePhone] ?? '',
      header: settings[SettingKeys.receiptHeader] ?? '',
      footer: settings[SettingKeys.receiptFooter]?.isNotEmpty == true
          ? settings[SettingKeys.receiptFooter]!
          : 'Terima kasih telah berbelanja',
      paperSize: settings[SettingKeys.paperSize] == '80'
          ? PaperSize.mm80
          : PaperSize.mm58,
    );

    final printer = ref.read(printerServiceProvider);
    final outcome = await printer.printReceipt(
      sale,
      store,
      mac: settings[SettingKeys.printerMac],
    );

    if (!mounted) return;
    if (outcome == PrintOutcome.success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Struk tercetak.')));
    } else {
      // Fallback: tampilkan pratinjau struk di layar.
      await _showPreviewDialog(sale, store, outcome);
    }
  }

  Future<void> _showPreviewDialog(
    Sale sale,
    StoreReceiptInfo store,
    PrintOutcome outcome,
  ) {
    final text = const ReceiptTextPreview().build(sale, store);
    final reason = switch (outcome) {
      PrintOutcome.notConnected => 'Printer belum terhubung.',
      PrintOutcome.noPermission => 'Izin Bluetooth belum diberikan.',
      PrintOutcome.error => 'Terjadi kesalahan saat mencetak.',
      PrintOutcome.success => '',
    };
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pratinjau Struk'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reason.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '$reason Menampilkan pratinjau.',
                    style: ctx.texts.bodySmall?.copyWith(
                      color: ctx.appColors.textMuted,
                    ),
                  ),
                ),
              Text(text, style: const TextStyle(fontFamily: 'monospace')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _QuickCash extends StatelessWidget {
  const _QuickCash({
    required this.total,
    required this.onExact,
    required this.onAdd,
  });

  final int total;
  final VoidCallback onExact;
  final void Function(int) onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _cashChip(context, 'UANG PAS', onExact),
        _cashChip(context, '20rb', () => onAdd(20000)),
        _cashChip(context, '50rb', () => onAdd(50000)),
        _cashChip(context, '100rb', () => onAdd(100000)),
      ],
    );
  }

  Widget _cashChip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: context.appShapes.chipRadius,
        side: BorderSide(color: context.appColors.hairline),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onTripleZero,
    required this.onBackspace,
    required this.onClear,
  });

  final void Function(String) onDigit;
  final VoidCallback onTripleZero;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final keys = <String>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '000',
      '0',
      '<',
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, i) {
        final key = keys[i];
        return _KeyButton(
          label: key,
          onTap: () {
            switch (key) {
              case '000':
                onTripleZero();
              case '<':
                onBackspace();
              default:
                onDigit(key);
            }
          },
          onLongPress: key == '<' ? onClear : null,
        );
      },
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerHighest,
      borderRadius: context.appShapes.buttonRadius,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: context.appShapes.buttonRadius,
        child: Center(
          child: label == '<'
              ? const Icon(Icons.backspace_outlined)
              : Text(label, style: context.texts.titleMedium),
        ),
      ),
    );
  }
}
