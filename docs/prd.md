# Product Requirements Document (PRD) — POSWaroeng

Status: v1, disusun 2026-08-25.
Dokumen ini merujuk tiga dokumen sumber tanpa menduplikasinya:
[riset pasar](riset-pasar.md) · [spesifikasi UI/UX](ui-ux-spec.md) · [arsitektur teknis](arsitektur-teknis.md).
Invarian kunci proyek ada di [AGENTS.md](../AGENTS.md).

---

## 1. Ringkasan Produk

**POSWaroeng** adalah aplikasi Android kasir + manajemen stok + pembukuan ringkas untuk **warung kelontong dan UMKM Indonesia**. Dibangun dengan Flutter, data tersimpan lokal di perangkat (SQLite), bekerja 100% offline.

**Posisi satu kalimat:** *aplikasi stok & kasir grosir-kelontong yang paham satuan (dus/box/pcs), 100% offline, 100% gratis, tanpa daftar — data milik Anda sendiri.*

**Untuk siapa:**
- Pemilik warung kelontong yang membeli barang **per dus/karton** tapi menjual **eceran per pcs**, dan selama ini menghitung konversi stok secara manual (atau tidak mencatat sama sekali).
- Pemilik usaha kecil multi-peran (toko sembako, kios pulsa, laundry + jualan) yang butuh catatan penjualan, pengeluaran, dan stok dalam satu aplikasi ringan di HP yang sudah dimiliki.

**Prinsip produk:** gratis penuh tanpa fitur terpangkas, offline murni tanpa akun/cloud, zero-friction (buka langsung pakai), UI Bahasa Indonesia, data tidak pernah keluar dari perangkat.

---

## 2. Masalah & Nilai

Detail bukti dan tabel kompetitor ada di [docs/riset-pasar.md](riset-pasar.md); berikut intinya sebagai dasar keputusan produk:

1. **Multi-satuan bertingkat adalah diferensiator #1.** Warung membeli per dus, menjual per pcs — tapi dari 10+ aplikasi POS yang diriset, **tidak satu pun** menyediakan konversi satuan bertingkat (1 DUS = 10 BOX = 100 PCS) lengkap dengan barcode berbeda per satuan + harga beli per satuan, secara gratis. Yang paling dekat dikunci di paywall (Majoo Advance+, plugin Kasir Pintar) atau berupa bundel BOM yang bukan konversi sejati (iREAP Pro). Ini celah pasar nyata dan cocok dengan kekuatan arsitektur offline SQLite kami.
2. **Kombinasi "gratis penuh + offline murni + tanpa akun" hampir unik.** Hampir semua kompetitor wajib registrasi akun + cloud; "offline" mereka umumnya berarti offline-lalu-sinkron. Satu-satunya pembanding tanpa daftar (iREAP Lite) sengaja dipangkas fiturnya. POSWaroeng menawarkan kombinasi ini **tanpa pangkas**: laporan tak terbatas, tanpa watermark struk, tanpa iklan, tanpa batas produk — hal-hal yang biasanya menjadi umpan paywall kompetitor.
3. **Fitur dasar kasir itu table-stakes.** Pencarian produk, total, kembalian, struk thermal Bluetooth, stok sederhana, laporan harian — semua kompetitor punya, banyak yang gratis. Kami tetap wajib punya (tiket masuk), tapi tidak menjualnya sebagai nilai utama.

**Nilai bagi pengguna:** hilangkan hitung-konversi manual dan salah stok saat beli-dus-jual-pcs; nol biaya langganan; nol hambatan onboarding; ketahanan saat internet buruk/tidak ada; kepemilikan penuh data lewat backup file lokal.

---

## 3. Persona Pengguna

### Persona A — Bu Sari, pemilik warung kelontong (persona utama)
- 45 tahun, warung sembako & kelontong di depan rumah. Membeli stok mingguan dari distributor: **per dus/karton**. Menjual eceran per pcs, kadang per renceng/pack.
- Bukan orang teknis: hanya familiar WhatsApp dan galeri foto. Tidak mau isi formulir panjang, tidak punya email aktif, internet sering putus.
- Pain point hari ini: menghitung ulang "dus tinggal 2 setengah" saat mau jual 1 dus padahal eceran duluan; salah hitung uang; lupa hutang supplier; tidak tahu untung rugi harian.
- Kebutuhan: scan/ketuk → jual → struk, dalam hitungan detik; stok otomatis turun sesuai satuan; angka besar dan jelas.

### Persona B — Pak Dedi, pemilik usaha kecil multi-peran
- 32 tahun, punya kios ATK + fotokopi, merangkap kasir, pembeli, dan pembukuan sendiri. Lebih melek digital, tapi waktu terbatas.
- Ingin satu aplikasi untuk: transaksi harian, catat pengeluaran listrik/ATK, lihat laba kotor, cek produk apa yang menipis — tanpa berlangganan dan tanpa data bisnisnya di server orang lain.
- Kebutuhan: laporan cepat per tanggal, riwayat transaksi yang bisa dicari, backup rutin karena HP bisa rusak/hilang.

---
## 4. Fitur & User Stories

Status per fitur mengikuti roadmap ([arsitektur teknis §6](arsitektur-teknis.md)):
**SELESAI** = sudah ada sejak Fase 0–1 · **RENCANA** = menyusul di Fase 2–6.
Desain layar merujuk [ui-ux-spec.md](ui-ux-spec.md); logika data merujuk [arsitektur-teknis.md](arsitektur-teknis.md).

### 4.1 Beranda (dashboard) — SELESAI
- **Cerita:** Sebagai pemilik warung, saya ingin melihat ringkasan pendapatan, profit, dan kondisi toko dalam satu layar, sehingga saya tahu kondisi usaha tanpa buka laporan.
- **Kriteria terima:**
  - Kartu hero menampilkan pendapatan hari ini, profit hari ini, jumlah transaksi, dan jumlah produk stok menipis — semuanya dari DB nyata.
  - Grid 6 menu utama (Produk, Stok, Barang Masuk, Pengeluaran, Laporan, Riwayat) sesuai kontrak UI/UX; tiap kotak membuka modulnya atau placeholder "segera hadir" yang jelas.
  - Tombol TRANSAKSI selalu terlihat dan membuka kasir dalam ≤ 1 ketukan.

### 4.2 Produk — SELESAI (Fase 1, dasar PCS)
- **Cerita:** Sebagai pemilik warung, saya ingin mencatat produk beserta kode/barcode, kategori, harga beli, harga jual, dan stok minimum, sehingga katalog saya rapi dan bisa dicari cepat saat jualan.
- **Kriteria terima:**
  - CRUD produk lengkap: nama, kode/SKU, barcode, kategori, harga beli/jual (int rupiah), stok minimum.
  - Pencarian produk di kasir memakai prefix-match (`LIKE 'kata%'`) dengan hasil instan pada katalog ribuan item.
  - Soft delete: produk yang dihapus tidak muncul di katalog tetapi riwayat transaksi lamanya tetap valid.

### 4.3 Satuan (multi-satuan bertingkat) — RENCANA (Fase 2, pembeda #1)
- **Cerita:** Sebagai pemilik warung, saya ingin mendefinisikan satuan DUS/BOX/PCS per produk dengan faktor konversi, barcode berbeda, dan harga per satuan, sehingga saya bisa beli per dus dan jual eceran tanpa hitung ulang manual.
- **Kriteria terima:**
  - Per produk bisa punya ≥1 satuan; satuan dasar (PCS) faktor = 1; BOX/DUS punya `conversion_to_base` ke PCS.
  - Barcode unik per satuan; scan barcode DUS otomatis menjual sebagai DUS.
  - Harga beli dan harga jual dapat berbeda per satuan.
  - Stok fisik disimpan tunggal dalam PCS (`products.stock_base`); setiap mutasi menulis baris `stock_movements` dalam transaksi yang sama; invariant `SUM(stock_movements.qty_base) == products.stock_base` teruji unit test.
  - Jual DUS saat "stok DUS habis" tapi PCS cukup → transaksi tetap boleh (pecah otomatis), dengan keterangan halus di UI — bukan penolakan.

### 4.4 Kasir — SELESAI (Fase 1, tunai + PCS)
- **Cerita:** Sebagai pemilik warung, saya ingin mencatat transaksi jual cepat — cari/scan produk, total otomatis, input uang bayar, kembalian dihitung — sehingga antrean pembeli tidak menunggu.
- **Kriteria terima:**
  - Katalog daftar/grid bisa diganti pengguna; default daftar padat (sesuai keputusan Q3).
  - Keranjang menempel di bawah: jumlah item, total, tombol BAYAR selalu terlihat.
  - Sheet bayar: tombol pecahan cepat (20rb/50rb/100rb/uang pas) + keypad angka besar; kembalian ditonjolkan hijau.
  - Posting `sales` + `sale_items` + `stock_movements` + update `stock_base` dalam SATU transaction sqflite (atomik).
  - Waktu dari buka kasir sampai transaksi tersimpan untuk keranjang 3 item ≤ 10 detik (metrik §7).
  - Chip satuan di item keranjang (PCS/BOX/DUS) menyusul di Fase 2 bersama fitur Satuan.

### 4.5 Barang Masuk (pembelian + hutang supplier) — RENCANA (Fase 3)
- **Cerita:** Sebagai pemilik warung, saya ingin mencatat barang masuk dari distributor beserta hutangnya, sehingga stok naik otomatis dan saya tidak lupa utang dagang.
- **Kriteria terima:**
  - Input pembelian: pilih satuan beli (DUS/BOX/PCS) → pratinjau konversi tampil SEBELUM simpan ("+288 pcs masuk gudang").
  - Simpan menambah stok via ledger (`type: PURCHASE`) dalam satu transaction.
  - Status pembayaran LUNAS / HUTANG / SEBAGIAN dengan jatuh tempo; pembayaran hutang bertahap tercatat (`supplier_payments`).

### 4.6 Stok — RENCANA (Fase 2)
- **Cerita:** Sebagai pemilik warung, saya ingin melihat sisa stok semua produk dan melakukan penyesuaian hasil opname, sehingga angka aplikasi cocok dengan rak.
- **Kriteria terima:**
  - Daftar stok dengan indikator menipis/habis (ambang `min_stock_base`, warna amber/merah dari tema).
  - Penyesuaian manual (opname/koreksi) menulis `stock_adjustments` + baris ledger `ADJUST` dalam satu transaction.
  - Alert stok minimum muncul di Beranda (pil "N produk menipis").

### 4.7 Pengeluaran — RENCANA (Fase 4)
- **Cerita:** Sebagai pemilik usaha, saya ingin mencatat pengeluaran operasional (listrik, plastik, transport), sehingga laba yang saya lihat adalah laba bersih, bukan cuma omzet.
- **Kriteria terima:**
  - Catat pengeluaran: nominal (int rupiah), kategori, deskripsi, tanggal.
  - Kategori pengeluaran bisa dikelola (tambah/nonaktifkan).
  - Pengeluaran ikut masuk perhitungan rekap harian.

### 4.8 Laporan — RENCANA (Fase 4)
- **Cerita:** Sebagai pemilik usaha, saya ingin melihat laporan penjualan, stok, barang masuk, pengeluaran, dan rekap laba dengan filter tanggal TANPA batas rentang waktu dan tanpa watermark, sehingga saya tahu untung rugi kapan pun.
- **Kriteria terima:**
  - Laporan: penjualan, stok, barang masuk, pengeluaran, rekap harian (penjualan − pengeluaran − HPP).
  - Filter tanggal bebas — tidak ada pembatasan "30 hari" seperti kompetitor gratis.
  - Angka profit konsisten: berasal dari snapshot HPP pada `sale_items`, bukan harga master saat ini.

### 4.9 Riwayat — RENCANA (Fase 2+)
- **Cerita:** Sebagai pemilik warung, saya ingin mencari ulang transaksi lampau dan melihat riwayat mutasi stok per produk, sehingga saya bisa menelusuri selisih atau jawab komplain pelanggan.
- **Kriteria terima:**
  - Daftar transaksi penjualan terurut waktu, bisa dibuka detail itemnya (snapshot nama/satuan/harga saat transaksi — kebal edit master).
  - Riwayat mutasi stok per produk membaca `stock_movements`.
  - Riwayat tak terbatas rentang waktu (data lokal).

### 4.10 Struk — SELESAI (Fase 1, dasar) → lanjut Fase 5
- **Cerita:** Sebagai pemilik warung, saya ingin mencetak struk ke printer thermal Bluetooth, sehingga pembeli dapat bukti transaksi dan pencatatan saya resmi terasa.
- **Kriteria terima (tercapai F1):**
  - Cetak ESC/POS via Bluetooth Classic 58/80mm; fallback pratinjau struk di layar bila printer tidak tersedia.
  - Header/footer dari Pengaturan; izin BT API 31+ runtime tanpa permintaan lokasi (`neverForLocation`).
- **Kriteria terima (F5):**
  - Layout parametrik penuh 58mm/80mm, logo, QR; item satuan non-dasar mencantumkan satuan di nama ("Mie Goreng DUS"); QRIS sebagai metode bayar pilihan tanpa mengubah layout.

### 4.11 Pengaturan — SELESAI (Fase 1, dasar) → lanjut Fase 5
- **Cerita:** Sebagai pemilik warung, saya mengisi nama/alamat/telp toko sekali di awal, sehingga struk dan identitas aplikasi benar.
- **Kriteria terima (tercapai F1):** identitas toko + pilih printer paired disimpan di tabel `settings` (key-value).
- **Kriteria terima (F5):** format struk (paper size, header/footer bebas), pajak/diskon default, onboarding satu layar opsional "isi nama toko" yang bisa dilewati.

### 4.12 Backup & Restore — RENCANA (Fase 5)
- **Cerita:** Sebagai pemilik warung, saya ingin menyimpan salinan seluruh data aplikasi ke file dan memulihkannya di HP lain, sehingga HP rusak tidak berarti usaha saya hilang catatannya — tanpa harus membuat akun cloud.
- **Kriteria terima:**
  - Ekspor file `.db` via SAF/share (ke Drive/WA/email — pengguna memegang filenya).
  - Impor: validasi file adalah DB POSWaroeng (cek `PRAGMA user_version`), jalankan migrasi bila versi lama, backup file lama dulu sebelum menimpa, tangani checkpoint WAL agar transaksi terakhir tidak hilang.
  - Restore sukses = seluruh data (produk, transaksi, riwayat) kembali persis seperti saat ekspor.

---
## 5. Ruang Lingkup per Fase

Detail teknis tiap fase ada di [arsitektur-teknis.md §6](arsitektur-teknis.md); ringkasannya:

| Fase | Isi | Status |
|---|---|---|
| **0 — Fondasi** | Scaffold Flutter feature-first, skema DB v1 (14 tabel) + kerangka migrasi, tema biru + Plus Jakarta Sans, locale id_ID, CI (`analyze`+`test`+build APK debug), unit test pertama | SELESAI |
| **1 — Kasir MVP** | Beranda, CRUD produk dasar, kasir end-to-end (cari→keranjang→bayar→kembalian→posting atomik), cetak struk BT 58/80mm dengan fallback layar, pengaturan toko+printer | SELESAI |
| **2 — Multi-satuan penuh + stok** | `product_units` (konversi, barcode & harga per satuan), chip satuan di kasir, scan barcode (`mobile_scanner`), manajemen stok + riwayat mutasi, penyesuaian opname, alert stok minimum | RENCANA |
| **3 — Pembelian & hutang** | Barang masuk dengan pratinjau konversi, hutang supplier (status, jatuh tempo, bayar bertahap) | RENCANA |
| **4 — Pengeluaran & laporan** | Pengeluaran + kategori, laporan penjualan/stok/masuk/pengeluaran/rekap laba dengan filter tanggal bebas | RENCANA |
| **5 — Struk lanjut + backup + polish** | Struk parametrik penuh (logo/QR/pajak/diskon), backup/restore SQLite via SAF/share, pengaturan lengkap; FTS5 opsional bila katalog besar terasa lambat | RENCANA |
| **6 — Signed release** | Aktifkan slot signing di CI workflow, rilis APK `--release` signed via tag `v*` | RENCANA |

Prinsip roadmap: potongan awal bisa di-build dan diuji via CI secepat mungkin, lalu fitur ditambah inkremental tanpa membongkar skema.

---

## 6. Batasan Non-Fungsional

- **Offline murni:** semua fitur wajib bekerja tanpa internet sama sekali. Tidak ada registrasi akun, tidak ada sinkronisasi cloud. Onboarding = buka aplikasi → langsung pakai.
- **CI-only verification:** tidak ada build lokal di mesin pengembang; GitHub Actions adalah satu-satunya verifikator (`flutter analyze` + `flutter test` + build APK). Maksimalkan logika dalam unit test yang jalan di runner Linux (`sqflite_common_ffi`).
- **Uang = int rupiah bulat** (tanpa sen); dilarang `double` untuk uang.
- **Stok tunggal satuan dasar:** stok hanya disimpan di `products.stock_base` (PCS); setiap perubahan menulis `stock_movements` dalam transaksi yang sama; invariant ledger teruji otomatis.
- **Performa katalog besar:** pencarian prefix ber-index, paginasi, debounce pencarian (~250ms), lookup barcode O(log n); target tetap responsif pada 5.000+ produk sebelum FTS5 dipertimbangkan.
- **Privasi:** data bisnis tidak pernah keluar dari perangkat; satu-satunya jalur keluar adalah file backup yang eksplisit dibagikan pengguna sendiri.
- **Bahasa Indonesia** untuk seluruh UI dan dokumen; struktur kode siap i18n bila kelak dibutuhkan.
- **Kompatibilitas perangkat:** minSdk 21 (Android 5.0), naik ke 23 hanya jika plugin jalur kritis menuntut (lihat asumsi terbuka).

---

## 7. Metrik Keberhasilan

Usulan metrik yang terukur:

1. **Kecepatan transaksi:** input 1 transaksi kasir (3 item, tunai) tuntas tersimpan < 10 detik oleh pengguna terbiasa.
2. **Zero-friction onboarding:** dari instal APK sampai transaksi pertama tersimpan < 30 detik, tanpa membuat akun apa pun.
3. **Akurasi konversi satuan:** nol selisih antara `SUM(stock_movements.qty_base)` dan `products.stock_base` — diverifikasi unit test hijau di setiap merge (invariant ledger).
4. **CI hijau tiap merge:** 100% merge ke main lolos gate analyze+test; APK debug artifact tersedia di setiap push main.
5. **Ketersediaan offline:** 100% alur inti (jual, stok, laporan, backup) dapat diselesaikan dalam mode pesawat.
6. **Adopsi diferensiator:** setelah Fase 2 rilis, ≥ 50% produk aktif di katalog uji memiliki >1 satuan (indikator fitur unggulan benar-benar dipakai).
7. **Waktu loop pengembangan:** commit → CI hijau → APK siap unduh < 15 menit (dengan cache Gradle/SDK).

---

## 8. Keputusan Terkunci & Asumsi Terbuka

### Keputusan terkunci (final dari captain — jangan diubah pekerja implementasi)
- Desain biru modern, seed `#2563EB`, font Plus Jakarta Sans, Material 3, dark mode ikut sistem ([ui-ux-spec.md](ui-ux-spec.md)).
- Beranda: kartu hero Laporan Hari Ini + grid **6 menu utama** (Produk, Stok, Barang Masuk, Pengeluaran, Laporan, Riwayat) + tombol TRANSAKSI; Satuan dilebur ke Produk, Kasir lewat tombol TRANSAKSI.
- Interaksi multi-satuan di kasir: **chip satuan + pecah otomatis ke PCS**, tanpa dialog pilih-satuan muncul-tutup; scan barcode menentukan satuan; input manual default PCS.
- Katalog kasir: daftar/grid bisa disaklar pengguna, default daftar padat (keputusan Q3).
- Model produk: **gratis penuh, offline murni, tanpa akun/cloud**; UI Bahasa Indonesia.
- Distribusi APK via GitHub Releases (APK debug dulu; signed release menyusul di Fase 6); build & verify CI-only.
- Arsitektur: Flutter feature-first, Riverpod, SQLite lokal, uang int rupiah, ledger stok `stock_movements`.

### Asumsi terbuka — **perlu konfirmasi captain**
- **minSdk 21 vs 23:** kemungkinan naik ke 23 saat integrasi `mobile_scanner` (Fase 2). Keputusan teknis mengikuti kebutuhan plugin, tapi dampak jangkauan perangkat layak dikonfirmasi.
- **QRIS / pembayaran non-tunai:** direncanakan "menyusul" sebagai pilihan metode; belum ada komitmen fase. Perlu keputusan timing (F5 atau lebih belakangan).
- **PIN/kasir multi-user lokal (Prioritas 7 riset):** ada di riset pasar sebagai peluang, **belum diputuskan** masuk roadmap atau tidak.
- **Cetak label barcode per satuan (Prioritas 6 riset):** pelengkap alami multi-satuan, belum ada di roadmap fase mana pun — perlu keputusan.
- **Harga grosir/bundel (Product Set):** disebut riset sebagai umpan akuisisi; belum dirinci sebagai fitur.
- **FTS5 untuk katalog besar:** keputusan "tunggu sampai terasa lambat" (≥±5.000 item) — ambang nyamanya perlu divalidasi dengan data nyata.
- **Nama package final** `id.poswaroeng.app`: masih bisa berubah bila akan rilis Play Store kelak.
- **Lisensi repo:** belum ditentukan.
- **Monetisasi jangka panjang:** saat ini gratis penuh tanpa model pendapatan; keberlanjutan (donasi? layanan lain?) belum diputuskan captain.

---

## 9. Di Luar Ruang Lingkup (Non-Goals)

Untuk saat ini, POSWaroeng sengaja **tidak** membangun:

- **Multi-outlet real-time / sinkronisasi antar-perangkat** — bertentangan dengan model offline single-device; desain DB sudah menyisipkan kolom untuk sync masa depan tanpa janji.
- **Payroll / manajemen karyawan / shift.**
- **Marketplace / toko online / integrasi e-commerce.**
- **Sinkronisasi cloud & akun pengguna** — data milik perangkat; backup file adalah mekanisme kepemilikan data.
- **Pembayaran elektronik terintegrasi** (kartu, e-wallet API) — QRIS menyusul sebagai catatan metode, bukan integrasi payment gateway.
- **Fitur akuntansi lengkap** (jurnal, pajak pajakan, neraca) — cukup rekap laba kotor harian.

---

*PRD ini hidup: setiap keputusan captain baru harus dicatat di bagian §8, dan status fitur §4 diperbarui saat fase selesai.*
