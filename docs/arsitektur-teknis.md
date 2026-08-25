> Snapshot per 2026-08-25. Repo ini adalah sumber kebenaran; dokumen ini disalin utuh dari rencana teknis final tanpa mengubah substansi kontrak.

# Rencana Arsitektur Teknis POSWaroeng

Aplikasi Android kasir + manajemen toko. Flutter/Dart, SQLite (sqflite) lokal murni, offline. Build via GitHub Actions (tanpa build lokal di Termux), distribusi APK via GitHub Releases. Printer thermal Bluetooth ESC/POS 58/80mm. UI Bahasa Indonesia.

---

## Ringkasan Eksekutif

POSWaroeng dirancang sebagai aplikasi Flutter **offline-first murni** dengan penyimpanan lokal SQLite via `sqflite`. Rekomendasi utama:

- **Struktur proyek:** *feature-first* dengan lapisan `data/domain/presentation` per fitur, ditopang folder `core/` bersama. **State management: Riverpod** (`flutter_riverpod` ^3.x) karena testable tanpa emulator (kritis saat tidak ada build lokal), dependency injection built-in, dan cocok untuk data reaktif dari DB.
- **Database:** stok **selalu disimpan dalam satuan dasar (PCS)** di kolom tunggal `products.stock_base`. Multi-satuan (PCS/BOX/DUS) diwujudkan lewat tabel `product_units` dengan faktor konversi ke PCS; setiap transaksi menyimpan **snapshot** faktor, harga, dan nama satuan agar riwayat kebal terhadap perubahan master. Semua perubahan stok wajib lewat **satu ledger `stock_movements`** dan dibungkus **transaction sqflite** untuk konsistensi.
- **CI/CD:** GitHub Actions di `ubuntu-latest`, Flutter stable via `subosito/flutter-action@v2` (cache SDK + pub), **JDK 17** (Temurin). Gate `flutter analyze` + `flutter test` sebelum `flutter build apk`. Job `release` terpisah terpicu oleh **push tag** `v*`. Iterasi harian: commit kecil → CI hijau → unduh APK artifact / Release.
- **Printing:** `print_bluetooth_thermal` (tidak minta izin lokasi — penting agar lolos review Play & UX warung) + `esc_pos_utils_plus` sebagai generator ESC/POS. Layout struk dibuat parametrik terhadap lebar kertas (`PaperSize.mm58`/`mm80`).
- **minSdkVersion 21 (Android 5.0)** sebagai baseline; runtime-guard izin Bluetooth API 31+.

Keputusan skema hemat untuk sync masa depan (1 paragraf, lihat bagian 2) sudah dimasukkan tanpa merancang backend.

**Status verifikasi:** versi package di bawah **terverifikasi** dari pub.dev per **2026-08-25** (akses via webfetch). Hal yang belum bisa saya jalankan (build/test aktual) ditandai sebagai **asumsi** — worktree ini hanya berisi README placeholder, tidak ada proyek Flutter, dan Termux tidak punya toolchain build.

---

## 1. Struktur Proyek Flutter

### 1.1 Pola layering: feature-first + clean layering ringan

Rekomendasi: **feature-first** (bukan layer-first). Alasan konkret untuk POSWaroeng:

- Fitur (kasir, produk, barang masuk, stok, pengeluaran, laporan, pengaturan, backup) relatif independen dan dikembangkan bertahap sesuai roadmap MVP. Feature-first membuat tiap potongan MVP bisa di-*ship* dan di-*review* per folder tanpa menyentuh folder lain.
- Layer-first (`/models`, `/screens`, `/services` global) cepat membengkak dan bikin satu perubahan fitur menyebar ke banyak folder — mahal saat verifikasi hanya lewat CI.

Tiap fitur dibagi 3 lapis ringan (clean architecture yang dipangkas, jangan over-engineer untuk app lokal):

- **data**: DAO/repository implementasi (query sqflite), model/DTO `fromMap`/`toMap`.
- **domain**: entity + kontrak repository (abstract) + use-case bila logikanya non-trivial (mis. konversi satuan, posting ledger). Untuk CRUD sederhana, boleh langsung repository tanpa use-case.
- **presentation**: widget/screen + Riverpod providers/notifiers.

`core/` menampung yang lintas-fitur: koneksi & migrasi DB, util format uang/tanggal ID, layanan printer, helper backup SAF, konstanta, theme, extension.

### 1.2 State management: Riverpod (dengan alasan)

Perbandingan singkat untuk kasus POSWaroeng (offline, DB lokal, verifikasi hanya via CI):

| Kriteria | provider | Bloc | Riverpod (rekomendasi) |
|---|---|---|---|
| Boilerplate | Rendah | Tinggi (event/state class) | Sedang-rendah |
| Testability tanpa emulator | Perlu widget context | Baik (bloc_test) | **Sangat baik** — provider diuji sebagai unit murni via `ProviderContainer`, tanpa `WidgetTester` |
| DI / akses dependency | Manual via context | Perlu RepositoryProvider | **Built-in** (override provider) |
| Data reaktif dari DB (stream/future) | Manual | Cocok | **`FutureProvider`/`AsyncNotifier` native** (loading/error otomatis) |
| Kurva belajar | Termudah | Tercuram | Menengah |
| Cocok untuk transaksi kasir (state form kompleks) | Cukup | Sangat rapi | Rapi (`Notifier`) |

**Keputusan: `flutter_riverpod` ^3.x (terverifikasi 3.4.2, pub.dev 2026-08-25).** Faktor penentu adalah **testability tanpa emulator**: karena tidak ada build lokal, sebanyak mungkin logika (konversi satuan, kalkulasi total/kembalian, posting stok) harus bisa diuji sebagai *plain Dart unit test* yang jalan di `flutter test` pada CI. Riverpod memungkinkan menguji `Notifier`/`AsyncNotifier` lewat `ProviderContainer` dengan repository di-*override* oleh fake, tanpa merender widget. Bloc juga bagus di sini, tetapi boilerplate event/state lebih berat untuk tim kecil; provider klasik kalah di DI dan testabilitas. Gunakan **riverpod_generator** opsional bila mau `@riverpod` codegen — namun untuk MVP boleh manual agar tidak menambah beban build_runner di CI.

Catatan: hindari mencampur banyak solusi. Satu app = satu state management.

### 1.3 Strategi folder + nama package

Nama package (applicationId / bundle): `id.poswaroeng.app` (atau `com.<pemilik>.poswaroeng`). Package Dart: `poswaroeng`.

```
poswaroeng/
├─ pubspec.yaml
├─ analysis_options.yaml          # flutter_lints, aturan analyze ketat
├─ .github/workflows/ci.yml
├─ lib/
│  ├─ main.dart
│  ├─ app.dart                    # MaterialApp, theme, locale id_ID, router
│  ├─ core/
│  │  ├─ db/
│  │  │  ├─ app_database.dart      # openDatabase, onCreate, onUpgrade
│  │  │  ├─ migrations.dart        # daftar migrasi per versi
│  │  │  └─ schema.sql.dart        # DDL string terpusat (opsional)
│  │  ├─ format/
│  │  │  ├─ rupiah.dart            # NumberFormat id_ID
│  │  │  └─ tanggal.dart           # DateFormat id_ID
│  │  ├─ printing/
│  │  │  ├─ printer_service.dart   # koneksi BT, kirim bytes
│  │  │  └─ receipt_builder.dart   # generator ESC/POS 58/80mm
│  │  ├─ backup/
│  │  │  └─ backup_service.dart    # export/import file .db via SAF
│  │  ├─ theme/ , widgets/ , constants/ , error/
│  ├─ features/
│  │  ├─ kasir/            (data/ domain/ presentation/)
│  │  ├─ produk/
│  │  ├─ satuan/           # atau digabung ke produk
│  │  ├─ barang_masuk/     # pembelian + hutang supplier
│  │  ├─ stok/             # mutasi & riwayat
│  │  ├─ pengeluaran/
│  │  ├─ laporan/
│  │  ├─ pengaturan/       # toko/struk/printer
│  │  └─ backup/
│  └─ shared/              # model lintas fitur (mis. Money, Result)
└─ test/
   ├─ unit/                # konversi satuan, kalkulasi, migrasi DB (sqflite_common_ffi)
   └─ widget/
```

Untuk **unit test DB di CI** tanpa Android: gunakan `sqflite_common_ffi` agar SQLite jalan di VM Linux runner (`sqfliteFfiInit()` + `databaseFactoryFfi`). Ini membuat migrasi & query bisa diuji di `flutter test`/`dart test` pada `ubuntu-latest`.


---

## 2. Skema Database SQLite / sqflite

### 2.1 Prinsip desain

1. **Stok tunggal dalam satuan dasar (PCS).** `products.stock_base` menyimpan jumlah dalam PCS. Semua penjualan/pembelian dalam BOX/DUS dikonversi ke PCS sebelum menambah/mengurangi stok. Ini menghilangkan kelas bug "stok tidak sinkron antar satuan".
2. **Snapshot pada transaksi.** Baris item penjualan menyimpan salinan `unit_name`, `conversion_to_base`, `price` saat transaksi. Perubahan master (harga/satuan) di kemudian hari tidak mengubah riwayat.
3. **Ledger sebagai sumber kebenaran pergerakan stok.** Setiap perubahan stok menulis 1 baris `stock_movements`. `products.stock_base` adalah *cache* yang selalu di-update dalam **transaction** yang sama dengan penulisan ledger. `SUM(qty_base)` ledger harus selalu = `stock_base` (invariant yang bisa diuji).
4. **Uang sebagai INTEGER (rupiah bulat).** Rupiah tidak pakai sen; simpan sebagai `INTEGER` untuk hindari galat floating point. (sqflite tak punya DECIMAL.)
5. **Waktu sebagai INTEGER epoch millis** (UTC), diformat ke `id_ID` di UI. Alternatif TEXT ISO8601 juga sah; pilih satu konsisten.
6. **Soft delete** (`deleted_at`/`is_active`) untuk master (produk, supplier) agar riwayat lama tetap valid.

### 2.2 DDL sketch

```sql
-- ============ MASTER ============
CREATE TABLE categories (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          TEXT NOT NULL,
  is_active     INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE suppliers (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          TEXT NOT NULL,
  phone         TEXT,
  address       TEXT,
  is_active     INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE products (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  code            TEXT UNIQUE,             -- kode/SKU internal
  name            TEXT NOT NULL,
  category_id     INTEGER REFERENCES categories(id),
  supplier_id     INTEGER REFERENCES suppliers(id),
  base_unit       TEXT NOT NULL DEFAULT 'PCS',  -- label satuan dasar
  stock_base      REAL NOT NULL DEFAULT 0,      -- stok dalam satuan dasar (PCS)
  min_stock_base  REAL NOT NULL DEFAULT 0,      -- stok minimum (PCS) utk alert
  -- harga default satuan dasar (harga per-satuan detail ada di product_units)
  cost_price_base INTEGER NOT NULL DEFAULT 0,   -- harga beli per PCS (rupiah)
  sell_price_base INTEGER NOT NULL DEFAULT 0,   -- harga jual per PCS (rupiah)
  is_active       INTEGER NOT NULL DEFAULT 1,
  created_at      INTEGER NOT NULL,
  updated_at      INTEGER NOT NULL,
  deleted_at      INTEGER
);
CREATE INDEX idx_products_name     ON products(name);
CREATE INDEX idx_products_code     ON products(code);
CREATE INDEX idx_products_category ON products(category_id);

-- ============ MULTI SATUAN ============
-- Tiap produk punya >=1 baris satuan. Satuan dasar (PCS) faktor = 1.
-- BOX/DUS punya faktor konversi bertingkat yang DIRATAKAN ke satuan dasar.
CREATE TABLE product_units (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id          INTEGER NOT NULL REFERENCES products(id),
  unit_name           TEXT NOT NULL,          -- 'PCS' | 'BOX' | 'DUS' | bebas
  conversion_to_base  REAL NOT NULL,          -- berapa PCS per 1 satuan ini (PCS=1, BOX=12, DUS=144)
  barcode             TEXT,                   -- barcode BERBEDA per satuan
  cost_price          INTEGER NOT NULL DEFAULT 0,  -- harga beli per satuan ini (rupiah)
  sell_price          INTEGER NOT NULL DEFAULT 0,  -- harga jual per satuan ini (rupiah)
  is_base             INTEGER NOT NULL DEFAULT 0,
  sort_order          INTEGER NOT NULL DEFAULT 0,
  UNIQUE(product_id, unit_name)
);
CREATE UNIQUE INDEX idx_units_barcode ON product_units(barcode) WHERE barcode IS NOT NULL;
CREATE INDEX idx_units_product ON product_units(product_id);
```

**Konversi bertingkat:** meski konsep manusia bertingkat (1 DUS = 12 BOX, 1 BOX = 12 PCS), kolom `conversion_to_base` selalu menyimpan hasil rata ke PCS (DUS=144). UI input boleh minta "isi per tingkat" lalu aplikasi menghitung dan menyimpan nilai final ke PCS. Ini menyederhanakan query stok/harga: `qty_base = qty * conversion_to_base`.

```sql
-- ============ PEMBELIAN / BARANG MASUK + HUTANG ============
CREATE TABLE purchases (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_id    INTEGER REFERENCES suppliers(id),
  invoice_no     TEXT,
  purchase_date  INTEGER NOT NULL,
  total          INTEGER NOT NULL DEFAULT 0,   -- total rupiah
  paid_amount    INTEGER NOT NULL DEFAULT 0,   -- yang sudah dibayar
  status         TEXT NOT NULL DEFAULT 'LUNAS',-- LUNAS | HUTANG | SEBAGIAN
  due_date       INTEGER,                      -- jatuh tempo hutang
  note           TEXT,
  created_at     INTEGER NOT NULL
);
CREATE INDEX idx_purchases_supplier ON purchases(supplier_id);
CREATE INDEX idx_purchases_status   ON purchases(status);

CREATE TABLE purchase_items (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id         INTEGER NOT NULL REFERENCES purchases(id),
  product_id          INTEGER NOT NULL REFERENCES products(id),
  unit_name           TEXT NOT NULL,        -- snapshot satuan beli
  conversion_to_base  REAL NOT NULL,        -- snapshot faktor
  qty                 REAL NOT NULL,        -- jumlah dalam satuan beli
  qty_base            REAL NOT NULL,        -- qty * conversion_to_base
  cost_price          INTEGER NOT NULL,     -- snapshot harga beli/satuan
  subtotal            INTEGER NOT NULL
);
CREATE INDEX idx_purchase_items_purchase ON purchase_items(purchase_id);
CREATE INDEX idx_purchase_items_product  ON purchase_items(product_id);

-- Pembayaran hutang bertahap (opsional tapi murah disiapkan sekarang)
CREATE TABLE supplier_payments (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id  INTEGER NOT NULL REFERENCES purchases(id),
  amount       INTEGER NOT NULL,
  paid_at      INTEGER NOT NULL,
  note         TEXT
);

-- ============ PENJUALAN ============
CREATE TABLE sales (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_no     TEXT UNIQUE,               -- nomor struk
  sale_date      INTEGER NOT NULL,
  subtotal       INTEGER NOT NULL DEFAULT 0,
  discount       INTEGER NOT NULL DEFAULT 0,
  total          INTEGER NOT NULL DEFAULT 0,
  paid_amount    INTEGER NOT NULL DEFAULT 0, -- uang dibayar pelanggan
  change_amount  INTEGER NOT NULL DEFAULT 0, -- kembalian
  payment_method TEXT NOT NULL DEFAULT 'TUNAI',
  note           TEXT,
  created_at     INTEGER NOT NULL
);
CREATE INDEX idx_sales_date ON sales(sale_date);

CREATE TABLE sale_items (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id             INTEGER NOT NULL REFERENCES sales(id),
  product_id          INTEGER NOT NULL REFERENCES products(id),
  product_name        TEXT NOT NULL,        -- snapshot nama (kalau produk diedit)
  unit_name           TEXT NOT NULL,        -- snapshot satuan jual
  conversion_to_base  REAL NOT NULL,        -- snapshot faktor
  qty                 REAL NOT NULL,        -- jumlah dalam satuan jual
  qty_base            REAL NOT NULL,        -- qty * conversion_to_base (utk stok)
  sell_price          INTEGER NOT NULL,     -- snapshot harga/satuan saat jual
  cost_price          INTEGER NOT NULL DEFAULT 0, -- snapshot HPP/satuan utk laba
  subtotal            INTEGER NOT NULL
);
CREATE INDEX idx_sale_items_sale    ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product ON sale_items(product_id);

-- ============ LEDGER MUTASI STOK ============
CREATE TABLE stock_movements (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id   INTEGER NOT NULL REFERENCES products(id),
  qty_base     REAL NOT NULL,               -- (+) masuk, (-) keluar; SELALU satuan dasar
  balance_base REAL,                        -- saldo stok sesudah mutasi (opsional, audit)
  type         TEXT NOT NULL,               -- SALE | PURCHASE | ADJUST | OPENING | RETURN
  ref_table    TEXT,                        -- 'sales' | 'purchases' | 'adjustments'
  ref_id       INTEGER,                     -- id dokumen sumber
  note         TEXT,
  created_at   INTEGER NOT NULL
);
CREATE INDEX idx_movements_product ON stock_movements(product_id, created_at);
CREATE INDEX idx_movements_ref     ON stock_movements(ref_table, ref_id);

-- Penyesuaian stok manual (opname/koreksi)
CREATE TABLE stock_adjustments (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id   INTEGER NOT NULL REFERENCES products(id),
  qty_base     REAL NOT NULL,               -- selisih dalam satuan dasar
  reason       TEXT,
  created_at   INTEGER NOT NULL
);

-- ============ PENGELUARAN ============
CREATE TABLE expense_categories (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  name      TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE expenses (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id   INTEGER REFERENCES expense_categories(id),
  amount        INTEGER NOT NULL,
  description   TEXT,
  expense_date  INTEGER NOT NULL,
  created_at    INTEGER NOT NULL
);
CREATE INDEX idx_expenses_date     ON expenses(expense_date);
CREATE INDEX idx_expenses_category ON expenses(category_id);

-- ============ PENGATURAN (key-value + baris tunggal) ============
CREATE TABLE settings (
  key   TEXT PRIMARY KEY,   -- 'store_name','store_address','store_phone',
  value TEXT                --  'receipt_header','receipt_footer','paper_size',
);                          --  'printer_mac','printer_name','tax_percent', dst
```

`settings` sebagai key-value fleksibel & murah untuk ditambah. Pengaturan printer (MAC, nama, lebar kertas 58/80) dan struk (header/footer) disimpan di sini.

### 2.3 Menjaga konsistensi stok (transaction vs trigger)

**Rekomendasi: gunakan sqflite `db.transaction((txn) async {...})`, bukan SQL trigger.** Alasan:

- Logika bisnis (konversi satuan, hitung `qty_base`, hitung total/kembalian, update status hutang) hidup di Dart — lebih mudah diuji dengan unit test di CI (`sqflite_common_ffi`) ketimbang trigger SQL yang sulit dites tanpa emulator.
- Semua penulisan atomik dalam satu blok: insert `sales` + `sale_items` + `stock_movements` + update `products.stock_base` terjadi bersama; jika ada error, seluruhnya rollback (lempar exception di dalam transaction).

Pola posting penjualan (pseudocode):

```dart
await db.transaction((txn) async {
  final saleId = await txn.insert('sales', saleMap);
  for (final it in items) {
    final qtyBase = it.qty * it.conversionToBase;
    await txn.insert('sale_items', {...it.toMap(), 'sale_id': saleId, 'qty_base': qtyBase});
    // ledger keluar (negatif)
    await txn.insert('stock_movements', {
      'product_id': it.productId, 'qty_base': -qtyBase,
      'type': 'SALE', 'ref_table': 'sales', 'ref_id': saleId,
      'created_at': now,
    });
    await txn.rawUpdate(
      'UPDATE products SET stock_base = stock_base - ?, updated_at = ? WHERE id = ?',
      [qtyBase, now, it.productId]);
  }
}); // commit otomatis bila tak ada exception
```

Alternatif trigger (opsional pengaman): trigger `AFTER INSERT ON stock_movements` yang `UPDATE products.stock_base`. Ini menjamin `stock_base` selalu mengikuti ledger walau ada jalur tulis lain. Trade-off: harus tetap dijalankan di dalam transaction Dart, dan menyulitkan debugging. Untuk MVP, cukup transaction Dart + **invariant test**: `assert(SUM(stock_movements.qty_base WHERE product) == products.stock_base)`.

### 2.4 Strategi migrasi skema v1 → depan

- `openDatabase(path, version: N, onCreate:, onUpgrade:, onConfigure:)`. Di `onConfigure` aktifkan foreign keys: `await db.execute('PRAGMA foreign_keys = ON')`.
- `onCreate` menjalankan DDL versi terkini penuh.
- `onUpgrade(db, oldV, newV)` menjalankan daftar migrasi **inkremental** berurutan:

```dart
final migrations = <int, Future<void> Function(Database)>{
  2: (db) async { await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT'); },
  3: (db) async { await db.execute('CREATE TABLE supplier_payments (...)'); },
  // dst — setiap kenaikan versi = satu entri, tidak pernah mengedit entri lama
};
onUpgrade: (db, oldV, newV) async {
  for (var v = oldV + 1; v <= newV; v++) { await migrations[v]?.call(db); }
}
```

- Aturan: **jangan pernah mengubah migrasi yang sudah dirilis**; selalu tambah versi baru. SQLite `ALTER TABLE` terbatas (hanya ADD COLUMN / RENAME); untuk perubahan kompleks pakai pola *create-new-table → copy → drop → rename*.
- **Uji migrasi di CI**: buka DB versi lama (isi contoh), jalankan upgrade ke versi baru, assert skema & data. Ini menutup risiko "tidak ada build lokal" karena migrasi gagal baru ketahuan di device.

### 2.5 Catatan keputusan hemat untuk sync cloud masa depan (1 paragraf)

Hari ini, tanpa merancang backend, saya menambahkan biaya nyaris nol tapi bernilai besar untuk sync nanti: setiap tabel diberi kolom `created_at`/`updated_at` (epoch millis) dan pola **soft-delete** (`deleted_at`/`is_active`), plus desain **append-only ledger** (`stock_movements`) sebagai sumber kebenaran. Bila kelak sync ditambahkan, cukup menambah kolom `uuid TEXT` (client-generated) dan `sync_status`/`dirty` tanpa membongkar relasi: `updated_at` memungkinkan *delta sync* (kirim yang berubah sejak timestamp terakhir), soft-delete membuat penghapusan bisa direplikasi (tombstone), dan ledger append-only membuat rekonsiliasi stok antar-device deterministik. Kunci lokal `INTEGER AUTOINCREMENT` dipertahankan untuk performa; UUID ditambahkan sebagai identitas global saat sync diperlukan — keputusan ini menghindari migrasi besar di kemudian hari.


---

## 3. CI/CD GitHub Actions

### 3.1 Versi & alasan (terverifikasi pub.dev/docs, 2026-08-25)

- **Flutter: channel `stable`, pin versi eksplisit** (mis. `3.24.x` atau stable terbaru yang teruji). Pin versi memastikan build reprodusibel — kritis saat tidak ada build lokal, karena "works on my machine" tidak ada; CI adalah satu-satunya kebenaran. Simpan versi di `pubspec.yaml` (`environment: flutter: <versi>`) dan pakai `flutter-version-file: pubspec.yaml` agar satu sumber.
- **JDK: Temurin 17.** Android Gradle Plugin modern (AGP 8.x, dipakai template Flutter terbaru) **membutuhkan JDK 17**. JDK 17 adalah LTS dan default aman untuk toolchain Flutter Android saat ini. (Asumsi teknis: AGP 8 → JDK 17; verifikasi ulang bila template Flutter yang dipakai berbeda.)
- **Runner: `ubuntu-latest`** — Android APK bisa dibuild di Linux (tak perlu macOS). Termurah & tercepat.
- **Action: `subosito/flutter-action@v2`** (2.6k★, terverifikasi README GitHub 2026-08-25) dengan `cache: true` untuk cache SDK + pub.
- **Caching Gradle:** `actions/cache` untuk `~/.gradle/caches` dan `~/.gradle/wrapper` berkunci hash `**/*.gradle*` + `gradle-wrapper.properties`.

### 3.2 Workflow sketch — `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [ main ]
    tags:     [ 'v*' ]          # tag memicu job release
  pull_request:
    branches: [ main ]

env:
  FLUTTER_CHANNEL: stable

jobs:
  # ---------- GATE: analyze + test ----------
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          channel: ${{ env.FLUTTER_CHANNEL }}
          flutter-version-file: pubspec.yaml   # satu sumber versi
          cache: true                          # cache SDK + pub

      - run: flutter pub get
      - run: flutter analyze --fatal-infos      # gate analisis
      - run: flutter test --coverage            # gate test (unit + widget + migrasi DB via ffi)

  # ---------- BUILD debug APK ----------
  build-debug:
    needs: verify
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }

      - uses: subosito/flutter-action@v2
        with:
          channel: ${{ env.FLUTTER_CHANNEL }}
          flutter-version-file: pubspec.yaml
          cache: true

      # cache Gradle agar build cepat
      - uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: gradle-${{ runner.os }}-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: gradle-${{ runner.os }}-

      - run: flutter pub get
      - run: flutter build apk --debug
      - uses: actions/upload-artifact@v4
        with:
          name: poswaroeng-debug-apk
          path: build/app/outputs/flutter-apk/app-debug.apk
          retention-days: 14

  # ---------- RELEASE otomatis saat push tag ----------
  release:
    needs: verify
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    permissions:
      contents: write            # utk membuat GitHub Release
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }
      - uses: subosito/flutter-action@v2
        with:
          channel: ${{ env.FLUTTER_CHANNEL }}
          flutter-version-file: pubspec.yaml
          cache: true
      - uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: gradle-${{ runner.os }}-${{ hashFiles('**/*.gradle*') }}

      - run: flutter pub get

      # ---- BUILD PERTAMA: debug APK (signed release menyusul) ----
      - run: flutter build apk --debug
      - run: cp build/app/outputs/flutter-apk/app-debug.apk poswaroeng-${{ github.ref_name }}-debug.apk

      # ---- SLOT SIGNING (ditambah nanti tanpa restrukturisasi) ----
      # Saat siap rilis signed, aktifkan langkah di bawah:
      # - name: Decode keystore
      #   run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
      # - run: flutter build apk --release   # butuh key.properties dari secrets
      #   env:
      #     KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
      #     KEY_PASSWORD:      ${{ secrets.KEY_PASSWORD }}
      #     KEY_ALIAS:         ${{ secrets.KEY_ALIAS }}

      - name: Publish GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: poswaroeng-${{ github.ref_name }}-debug.apk
          generate_release_notes: true
```

### 3.3 Desain agar signing bisa ditambah tanpa restrukturisasi

- Konfigurasi Gradle `android/app/build.gradle` menyiapkan `signingConfigs.release` yang membaca file `android/key.properties` **bila ada**, dan **jatuh kembali ke debug signing bila tidak ada** (guard `if (keystorePropertiesFile.exists())`). Dengan begitu, debug APK jalan sekarang; ketika keystore + secrets tersedia, cukup tambah step decode keystore + `flutter build apk --release` — struktur workflow tidak berubah, hanya mengaktifkan langkah yang sudah disiapkan (di-comment di atas).
- Keystore disimpan sebagai secret base64 (`KEYSTORE_BASE64`) + password di GitHub Secrets. Tidak ada rahasia di repo.

### 3.4 Iterasi harian tanpa toolchain lokal (implikasi "tidak ada build lokal")

Karena Termux tidak bisa build/test Flutter Android, **CI adalah satu-satunya verifikator**. Alur kerja harian:

1. Edit kode di Termux (editor teks / opencode). Tidak menjalankan `flutter run`.
2. **Commit kecil & sering** → push ke branch/PR. Commit kecil mempersempit area kalau CI merah (debug lebih murah).
3. CI menjalankan gate: `flutter analyze` lalu `flutter test`. **Sebanyak mungkin logika diletakkan di unit test** (konversi satuan, kalkulasi total/kembalian, posting ledger, migrasi DB via `sqflite_common_ffi`) sehingga bug logika tertangkap tanpa perlu device.
4. Jika hijau, `build-debug` menghasilkan `app-debug.apk` sebagai **artifact** → unduh & pasang di HP untuk uji manual (printer BT, kamera scan) yang tak bisa diotomasi.
5. Uji end-to-end manual di device untuk hal fisik (Bluetooth, kamera). Untuk rilis, buat **tag `vX.Y.Z`** → job `release` menerbitkan APK ke GitHub Releases otomatis.

Konsekuensi desain: (a) `analysis_options.yaml` ketat + `--fatal-infos` agar galat gaya/nil-safety tertangkap dini; (b) hindari fitur yang hanya bisa diverifikasi manual di jalur kritis tanpa fallback test; (c) pertahankan waktu CI singkat lewat caching agar loop commit→APK cepat.


---

## 4. Pencetakan Bluetooth Thermal (Android)

### 4.1 Ekosistem package ESC/POS Flutter — perbandingan & risiko maintenance

| Package | Peran | Versi (pub.dev 2026-08-25) | Catatan / risiko |
|---|---|---|---|
| **`print_bluetooth_thermal`** | Transport BT klasik (SPP) + kirim bytes | 1.2.2 (3 bln lalu) | **Rekomendasi utama.** Dibuat justru sebagai alternatif yang **tidak minta izin lokasi** (Play Store memblok app yang minta lokasi tanpa alasan jelas). Publisher *unverified*, likes ~167 → risiko maintenance sedang; API kecil & stabil, mudah di-*fork* bila perlu. |
| **`esc_pos_utils_plus`** | Generator perintah ESC/POS (teks, tabel, gambar, barcode, QR, cut) | 2.0.4 (24 bln lalu) | **Rekomendasi pendamping** (pasangan alami dari package di atas — contoh resmi memakainya). Publisher terverifikasi (mylekha.app). **Risiko: 24 bulan tanpa update** → pantau kompatibilitas `image`/Dart 3; namun ESC/POS spec stabil, jadi risiko fungsional rendah. Fork aktif tersedia bila mangkrak. |
| `esc_pos_bluetooth` (andrey-ushakov) | Transport BT + generator | lama | Pendahulu; banyak yang pindah karena isu izin lokasi & maintenance. Hindari untuk proyek baru. |
| `blue_thermal_printer` | Transport BT SPP | aktif moderat | Alternatif transport; sebagian versi memicu permintaan izin lokasi. Cadangan. |
| `flutter_blue_plus` | BLE generic | sangat aktif | Untuk printer **BLE** (bukan SPP klasik). Lebih rumit (harus tulis karakteristik GATT sendiri). Pakai hanya jika printer target BLE-only. |

**Keputusan:** `print_bluetooth_thermal` (transport) + `esc_pos_utils_plus` (generator). Mitigasi risiko maintenance: bungkus keduanya di balik antarmuka `PrinterService` sendiri (`core/printing/`) sehingga bila salah satu package harus diganti/fork, hanya satu file adapter yang berubah — bukan seluruh app.

### 4.2 Permission Android modern

Mayoritas printer struk warung adalah **Bluetooth Classic (SPP)**. Deklarasi `AndroidManifest.xml`:

```xml
<!-- Android 12+ (API 31+): izin runtime baru -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation" />

<!-- Android <= 11 (API 30-): izin lama, hanya berlaku sampai maxSdk 30 -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<!-- Lokasi hanya diperlukan utk SCAN di API <= 30. Jika hanya pakai perangkat yg SUDAH
     dipasangkan (paired) via Setelan HP, lokasi bisa dihindari sepenuhnya. -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
    android:maxSdkVersion="30" />
```

Poin penting:
- Di **API 31+**, `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT` adalah **izin runtime** — minta saat runtime (mis. via `permission_handler`). `neverForLocation` menyatakan scan tidak dipakai untuk menurunkan lokasi → menghindari kewajiban izin lokasi.
- **Strategi paling bersih:** andalkan **perangkat yang sudah dipasangkan** lewat Setelan Bluetooth HP, lalu `PrintBluetoothThermal.pairedBluetooths` → `connect(mac)`. `print_bluetooth_thermal` secara desain **tidak meminta izin lokasi**, jadi lolos kebijakan Play dan UX warung lebih sederhana (pilih dari daftar paired).
- Di API ≤30, scanning perangkat baru butuh izin lokasi; batasi dengan `maxSdkVersion="30"`.

### 4.3 Strategi layout struk 58mm vs 80mm

- **Lebar karakter (font A default):** 58mm ≈ **32 kolom**, 80mm ≈ **48 kolom**. Simpan `paper_size` di `settings`; `receipt_builder` memilih `PaperSize.mm58`/`PaperSize.mm80` dan lebar kolom `row([PosColumn(width: ...)])` (grid 12) disesuaikan.
- **Builder parametrik:** satu fungsi `buildReceipt(paperSize, storeSettings, sale)` menghasilkan `List<int>` bytes. Hindari hardcode lebar; hitung dari `PaperSize`.
- **Tata letak umum:** header (nama toko, alamat, telp — dari `settings`, `align: center`) → garis pemisah → daftar item (`row`: nama | qty×harga | subtotal; untuk 58mm nama item bisa turun baris sendiri karena sempit) → subtotal/diskon/total → bayar/kembalian → footer (ucapan terima kasih). Gunakan `PosStyles(bold, align)` untuk total.
- **Gambar/logo & QR:** `generator.image()` (logo header) dan `generator.qrcode()`; hati-hati lebar gambar ≤ lebar kertas (mis. ≤384 dot untuk 58mm, ≤576 dot untuk 80mm).
- **Cut & feed:** akhiri `generator.feed(2)` lalu `generator.cut()` (jika printer mendukung). Beberapa printer 58mm murah tak punya auto-cutter → cukup feed.
- Test manual di device (tak bisa diotomasi di CI) untuk kalibrasi kolom per model printer; gunakan `CapabilityProfile.load('<model>')` bila karakter khusus/tabel kode bermasalah.


---

## 5. Risiko & Gotcha Teknis

### 5.1 Backup/restore file SQLite di scoped storage (SAF)

- Sejak Android 10+ (scoped storage), app **tidak lagi bebas** menulis ke `/sdcard`. File `.db` berada di *app-private* `getDatabasesPath()` (mis. `/data/data/<pkg>/databases/`) — aman tapi tidak terlihat user & ikut terhapus saat uninstall.
- **Backup:** tutup/checkpoint DB, salin file `.db` ke lokasi yang dipilih user lewat **Storage Access Framework**. Di Flutter: gunakan `file_picker` (`saveFile`/`getDirectoryPath`) atau paket SAF khusus untuk membuka *document picker*, lalu tulis salinan byte file DB. Alternatif praktis: `share_plus` untuk "bagikan" file backup (ke Drive/WA/email) — sederhana & andal untuk warung.
- **Restore:** buka *document picker* untuk memilih file `.db`, **tutup koneksi DB**, timpa file DB di `getDatabasesPath()`, buka ulang. Wajib: (a) validasi ini file DB POSWaroeng (cek `PRAGMA user_version`/tabel `settings`), (b) jalankan `onUpgrade` bila versi lama, (c) backup dulu file lama sebelum menimpa (rollback bila gagal).
- **Gotcha WAL:** bila memakai WAL, pastikan `PRAGMA wal_checkpoint(TRUNCATE)` atau tutup DB sebelum menyalin, agar `-wal`/`-shm` ter-flush ke file utama; kalau tidak, backup bisa kehilangan transaksi terakhir. Paling aman: `db.close()` → copy file → reopen.
- **minSdk & SAF:** SAF berlaku lintas versi; tidak butuh izin `WRITE_EXTERNAL_STORAGE` (yang deprecated). Ini poin penting agar tak minta izin storage luas → lolos review & privasi lebih baik.

### 5.2 Performa query katalog produk besar

- **Index** pada kolom pencarian: `products(name)`, `products(code)`, `product_units(barcode)` (unique partial), `sale_items(sale_id)`, `stock_movements(product_id, created_at)`. Sudah disertakan di DDL.
- **Pencarian produk kasir:** untuk katalog ribuan item, gunakan `LIKE 'kata%'` (prefix — bisa pakai index) daripada `LIKE '%kata%'` (full scan). Untuk pencarian substring/multi-kata yang cepat, pertimbangkan **FTS5** (`CREATE VIRTUAL TABLE products_fts USING fts5(name, code)`) yang di-*sync* via trigger — tambahkan bila katalog >±5.000 item terasa lambat (jangan prematur di MVP).
- **Paginasi**: jangan `SELECT *` semua produk ke memori; pakai `LIMIT/OFFSET` atau keyset pagination di daftar produk, dan debounce input pencarian (mis. 250ms).
- **Scan barcode**: lookup `product_units.barcode = ?` (indexed) → O(log n), instan meski katalog besar.
- **Laporan**: agregasi (`SUM`, `GROUP BY tanggal`) atas `sales`/`sale_items`/`expenses` dengan index tanggal; untuk rentang besar, pertimbangkan tabel ringkasan harian bila perlu (belum di MVP).
- **Batch insert** saat import/opname: gunakan `batch.commit(noResult: true)` dalam transaction agar cepat.

### 5.3 minSdkVersion — rekomendasi & trade-off

- **Rekomendasi: `minSdkVersion 21` (Android 5.0 Lollipop).** Ini default Flutter historis, kompatibel dengan hampir semua HP warung yang masih beredar (termasuk perangkat murah/lama), memaksimalkan jangkauan.
- **Trade-off:**
  - minSdk 21 → jangkauan maksimum, tapi harus *runtime-guard* fitur baru (izin BT API 31+ pakai pengecekan `Build.VERSION`). Package `print_bluetooth_thermal`/`mobile_scanner` mendukung rentang ini.
  - Naik ke **minSdk 23 (6.0)** menyederhanakan model izin runtime dan sebagian besar plugin modern nyaman di sini; kehilangan pangsa perangkat sangat lama yang kini kecil. **Ini kompromi wajar** bila plugin tertentu (mis. versi baru `mobile_scanner`/CameraX) menuntut ≥23.
  - Naik ke minSdk 26+ menambah kemudahan API tapi memotong perangkat lama — **tidak disarankan** untuk segmen warung.
- **Keputusan praktis:** mulai `minSdk 21`; naikkan ke 23 hanya jika ada plugin di jalur kritis yang mensyaratkannya. Catat: `mobile_scanner` (CameraX/MLKit) cenderung menuntut minSdk lebih tinggi — verifikasi saat menambahkannya (asumsi: 21 mungkin perlu naik ke 23 untuk scanner).

### 5.4 Keyboard / input angka rupiah

- Gunakan `TextField(keyboardType: TextInputType.number)` (atau `numberWithOptions`) untuk field harga/jumlah.
- **Formatter ribuan real-time**: `TextInputFormatter` kustom yang menyisipkan pemisah ribuan (titik, gaya ID: `10.000`) sambil menyimpan nilai murni `int` di state. Simpan uang sebagai `int` rupiah, format hanya untuk tampilan.
- Hindari `double` untuk uang (galat pembulatan). Qty boleh `double`/`num` bila jual per berat/eceran; untuk PCS gunakan bilangan.
- Sediakan tombol kalkulator/qty besar (numpad kustom) di kasir agar cepat dipakai kasir non-teknis.

### 5.5 Format tanggal & uang Indonesia

- Paket **`intl`**. Inisialisasi locale: `initializeDateFormatting('id_ID')` dan set `Intl.defaultLocale = 'id_ID'`.
- **Uang:** `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)` → `Rp 10.000`. `decimalDigits: 0` karena rupiah tanpa sen.
- **Tanggal:** `DateFormat('dd MMMM yyyy', 'id_ID')` → `25 Agustus 2026`; `DateFormat('dd/MM/yyyy HH:mm', 'id_ID')` untuk struk/riwayat.
- Set `MaterialApp(locale: Locale('id','ID'), supportedLocales: [...], localizationsDelegates: [...])`.
- Simpan waktu di DB sebagai epoch UTC; konversi ke lokal hanya saat tampil (hindari isu zona/DST walau Indonesia tak ber-DST — konsistensi tetap penting untuk sync masa depan).


---

## 6. Roadmap Bertahap

Prinsip: potongan pertama harus **bisa dibuild & diuji end-to-end via CI secepat mungkin**, lalu tambah fitur secara inkremental tanpa membongkar skema (skema §2 sudah mengakomodasi semua fitur — divalidasi di §6.2).

### 6.1 Urutan bertahap

**Fase 0 — Fondasi (target: CI hijau + APK debug pertama)**
- Scaffold proyek Flutter, `analysis_options.yaml` ketat, Riverpod, `intl` locale id_ID.
- `core/db`: openDatabase + skema v1 + migrasi framework + FK on.
- Setup `.github/workflows/ci.yml` (analyze + test + build-debug artifact).
- Unit test pertama: helper konversi satuan & format rupiah (membuktikan pipeline test jalan).
- **Deliverable:** APK debug kosong bisa dipasang; loop commit→CI→APK terbukti.

**Fase 1 — MVP kasir (end-to-end pertama yang berguna)**
- Manajemen produk minimal (CRUD produk + satuan dasar PCS, harga jual).
- Kasir: cari produk (prefix), tambah ke keranjang, hitung total, input bayar, hitung kembalian, simpan `sales`+`sale_items`+`stock_movements` dalam satu transaction.
- Struk sederhana: cetak ke printer BT 58mm (header/footer dari `settings`).
- Pengaturan toko dasar (nama/alamat/telp) + pilih printer paired.
- Unit test: posting penjualan mengurangi stok benar; total/kembalian benar; invariant ledger.
- **Deliverable:** alur jual→cetak struk bekerja di device.

**Fase 2 — Multi satuan penuh + stok**
- `product_units`: PCS/BOX/DUS, konversi ke PCS, barcode per satuan, harga beli/jual per satuan.
- Kasir memilih satuan saat jual (harga & qty_base ikut satuan); scan barcode per satuan (`mobile_scanner`).
- Manajemen stok + halaman riwayat mutasi (baca `stock_movements`), penyesuaian manual.
- Alert stok minimum.

**Fase 3 — Pembelian & hutang**
- Barang masuk (`purchases`+`purchase_items`) menambah stok via ledger (type PURCHASE).
- Hutang supplier (status, jatuh tempo, `supplier_payments`).

**Fase 4 — Pengeluaran & laporan**
- Pengeluaran + kategori; rekap harian (penjualan − pengeluaran − HPP = laba kotor).
- Laporan: penjualan, stok, barang masuk, pengeluaran, rekap (dengan filter tanggal).

**Fase 5 — Struk lanjutan + backup/restore + polish**
- Layout struk 80mm & 58mm parametrik penuh, logo/QR.
- Backup/restore SQLite via SAF/`share_plus`.
- Pengaturan aplikasi lengkap (format struk, pajak/diskon).
- (Opsional performa) FTS5 bila katalog besar.

**Fase 6 (kemudian) — Signed release**
- Aktifkan slot signing di workflow (keystore via secrets), rilis `--release` signed via tag.

### 6.2 Validasi: skema tidak menggagalkan satu pun fitur

| Fitur lengkap | Ditopang oleh |
|---|---|
| Kasir (cari, total, bayar, kembalian, harga per satuan) | `sales`, `sale_items` (snapshot harga+satuan), `paid_amount`/`change_amount`, `product_units.sell_price` |
| Manajemen produk | `products`, `categories`, `suppliers` |
| Multi satuan PCS/BOX/DUS + konversi + barcode per satuan | `product_units` (`conversion_to_base`, `barcode` unik/satuan, harga/satuan) |
| Barang masuk + hutang | `purchases`, `purchase_items`, `supplier_payments`, `status`/`due_date` |
| Manajemen stok + riwayat mutasi | `stock_movements` (ledger), `products.stock_base`, `stock_adjustments` |
| Pengeluaran + rekap harian | `expenses`, `expense_categories` (index tanggal) |
| Laporan penjualan/stok/masuk/pengeluaran/rekap | agregasi atas `sales`/`sale_items`/`purchases`/`stock_movements`/`expenses` |
| Struk thermal BT 58/80mm + header/footer | `settings` (paper_size, header, footer, printer_mac) + `receipt_builder` |
| Pengaturan aplikasi | `settings` (key-value fleksibel) |
| Backup/restore SQLite | file `.db` tunggal → SAF; kolom `created_at`/`updated_at`/soft-delete siap sync |

Semua fitur terpetakan ke tabel yang ada; tidak ada fitur yang menuntut perubahan struktural besar → skema aman untuk pengembangan bertahap.

---

## Lampiran: Sumber & Status Verifikasi

Semua URL diakses **2026-08-25** via webfetch.

**Terverifikasi (versi/fakta dari sumber resmi):**
- `flutter_riverpod` 3.4.2 — https://pub.dev/packages/flutter_riverpod
- `sqflite` 2.4.3 (tipe didukung: INTEGER/REAL/TEXT/BLOB; no bool/DateTime; transaction & batch) — https://pub.dev/packages/sqflite
- `print_bluetooth_thermal` 1.2.2 (tanpa izin lokasi; `isPermissionBluetoothGranted` utk API 12+) — https://pub.dev/packages/print_bluetooth_thermal
- `esc_pos_utils_plus` 2.0.4 (Generator, PaperSize.mm58/mm80, row/PosColumn, image, barcode, qrcode, cut) — https://pub.dev/packages/esc_pos_utils_plus
- `mobile_scanner` 7.4.0 (CameraX/MLKit Android) — https://pub.dev/packages/mobile_scanner
- `subosito/flutter-action@v2` (flutter-version-file, cache SDK+pub, contoh build apk) — https://github.com/subosito/flutter-action
- Flutter SDK archive / channel stable — https://docs.flutter.dev/install/archive

**Asumsi / perlu verifikasi di lingkungan build (tidak bisa saya jalankan di Termux, tanpa build lokal):**
- AGP 8.x ⇒ **JDK 17** — praktik umum toolchain Flutter Android saat ini; verifikasi terhadap template Flutter yang di-generate.
- `minSdk 21` cukup untuk semua plugin; kemungkinan perlu naik ke **23** demi `mobile_scanner`/CameraX terbaru — verifikasi saat integrasi.
- Lebar kolom struk (58mm≈32, 80mm≈48 kolom, font A) — angka umum ESC/POS; kalibrasi per model printer di device.
- Perilaku signing fallback Gradle (debug bila `key.properties` tak ada) — pola standar; uji saat menambah signing.
- Angka build time / efektivitas cache — belum diukur (tak ada CI run pada worktree ini; repo hanya README placeholder).

**Catatan lingkungan:** worktree hanya berisi `README.md` placeholder + `.opencode/`; belum ada proyek Flutter. Rekomendasi di atas adalah rancangan untuk diimplementasikan, bukan hasil eksekusi build/test aktual.
