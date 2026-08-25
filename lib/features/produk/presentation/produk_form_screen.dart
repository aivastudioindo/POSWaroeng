import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/theme/theme_x.dart';
import '../../app_providers.dart';
import '../domain/product.dart';
import '../domain/product_unit.dart';

/// Form tambah/edit produk minimal (nama, kode, harga jual, stok awal, min).
///
/// Satuan dasar PCS dibuat otomatis (pengaturan satuan lengkap = Fase 2).
class ProdukFormScreen extends ConsumerStatefulWidget {
  const ProdukFormScreen({super.key, this.productId});

  final int? productId;

  @override
  ConsumerState<ProdukFormScreen> createState() => _ProdukFormScreenState();
}

class _ProdukFormScreenState extends ConsumerState<ProdukFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _minStockCtrl = TextEditingController(text: '0');

  bool _loading = false;
  bool _initialized = false;
  Product? _existing;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _load();
    } else {
      _initialized = true;
    }
  }

  Future<void> _load() async {
    final repo = ref.read(productRepositoryProvider);
    final p = await repo.findById(widget.productId!);
    if (p != null && mounted) {
      _existing = p;
      _nameCtrl.text = p.name;
      _codeCtrl.text = p.code ?? '';
      _priceCtrl.text = p.sellPriceBase == 0
          ? ''
          : Rupiah.plain(p.sellPriceBase);
      _stockCtrl.text = p.stockBase.toStringAsFixed(0);
      _minStockCtrl.text = p.minStockBase.toStringAsFixed(0);
    }
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final repo = ref.read(productRepositoryProvider);
    final price = Rupiah.parse(_priceCtrl.text);
    final stock = double.tryParse(_stockCtrl.text.trim()) ?? 0;
    final minStock = double.tryParse(_minStockCtrl.text.trim()) ?? 0;
    final code = _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim();

    try {
      if (_isEdit && _existing != null) {
        final updated = _existing!.copyWith(
          name: _nameCtrl.text.trim(),
          code: code,
          sellPriceBase: price,
          stockBase: stock,
          minStockBase: minStock,
        );
        await repo.updateProduct(
          updated,
          units: [
            ProductUnit(
              unitName: updated.baseUnit,
              conversionToBase: 1,
              sellPrice: price,
              isBase: true,
            ),
          ],
        );
      } else {
        await repo.createProduct(
          Product(
            name: _nameCtrl.text.trim(),
            code: code,
            sellPriceBase: price,
            stockBase: stock,
            minStockBase: minStock,
            createdAt: 0,
            updatedAt: 0,
          ),
        );
      }
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
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
        title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(shapes.pagePadding),
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama produk'),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  SizedBox(height: shapes.gap),
                  TextFormField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Kode / SKU (opsional)',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: shapes.gap),
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Harga jual (Rp)',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final p = Rupiah.parse(v ?? '');
                      return p <= 0 ? 'Harga harus lebih dari 0' : null;
                    },
                  ),
                  SizedBox(height: shapes.gap),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Stok awal (PCS)',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(width: shapes.gap),
                      Expanded(
                        child: TextFormField(
                          controller: _minStockCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Stok minimum',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: shapes.gapLarge),
                  FilledButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SIMPAN'),
                  ),
                ],
              ),
            ),
    );
  }
}
