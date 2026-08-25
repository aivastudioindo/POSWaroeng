> Snapshot per 2026-08-25. Repo ini adalah sumber kebenaran; dokumen ini disalin utuh dari spesifikasi final tanpa mengubah substansi kontrak.

# Spesifikasi UI/UX Final — POSWaroeng

Status: disetujui captain 2026-08-25. Dokumen ini adalah acuan tunggal desain untuk implementasi Fase 0+1 dan seterusnya. Semua nilai konkret (warna, radius, font) di sini adalah kontrak; pekerja implementasi menuangkannya ke satu `AppTheme` terpusat, bukan hardcode per-widget.

---

## 0. Prinsip

- Modern, bukan "AI slop": ada karakter (gradien biru, bayangan berwarna, tipografi tegas), bukan widget default asal tempel.
- Pengguna dimudahkan dan tidak kebingungan: tugas harian satu ketukan, tanpa dialog muncul-tutup yang mengganggu, tanpa penolakan yang membingungkan.
- Satu sistem desain: warna, tipografi, bentuk, spasi bersumber dari satu tema. Material 3 (`useMaterial3: true`) sebagai fondasi.
- Bahasa UI: Indonesia. Uang: rupiah bulat (tanpa sen).

---

## 1. Palet warna — BIRU MODERN

Diterapkan lewat `ColorScheme.fromSeed` + token kustom (ThemeExtension).

| Token | Nilai | Pemakaian |
|---|---|---|
| Seed / primary | `#2563EB` (blue-600) | warna merek utama |
| Primary terang | `#3B82F6` / `#60A5FA` | ujung terang gradien |
| Primary dalam | `#1D4ED8` / `#1E40AF` | ujung gelap gradien, tekanan |
| Gradien hero & tombol | `linear-gradient(135deg,#3B82F6,#1E40AF)` | kartu Laporan Hari Ini, tombol TRANSAKSI, tombol BAYAR |
| Latar aplikasi | `#F4F7FB` (abu-biru sangat muda) | scaffold background |
| Kartu | `#FFFFFF` | semua kartu/permukaan |
| Teks utama | `#0F172A` (slate-900) | judul/angka |
| Teks redup | `#64748B` (slate-500) | subjudul, keterangan |
| Garis/pembatas | `#E7ECF3` | divider halus |
| Positif (uang masuk) | `#10B981` (emerald-500) | kembalian, profit naik, indikator ▲ |
| Peringatan | `#F59E0B` (amber-500) | stok menipis |
| Bahaya | `#EF4444` (red-500) | titik notifikasi, stok habis, hapus |

Ikon menu bergradasi warna per fungsi (biru/indigo/ungu/teal/amber/rose) agar tiap menu mudah dibedakan sekali lihat. Aksen hijau HANYA untuk angka positif (intuisi "uang masuk"); identitas aplikasi tetap biru.

Dark mode: ikut sistem HP (otomatis), tanpa saklar sendiri di MVP. `ColorScheme.fromSeed(brightness: dark)` dengan seed sama.

---

## 2. Tipografi & bentuk

- Font: **Plus Jakarta Sans** (via `google_fonts`), fallback sistem. Bobot 400/600/700/800.
- Skala: angka besar hero ~20–22px/800; judul kartu ~13px/800; teks utama ~12px; keterangan ~9–10px/600 warna redup.
- Radius: kartu 16px, kartu besar/hero 22px, tombol 14–16px, chip 999px (pil).
- Bayangan: lembut & sedikit berwarna biru pada elemen mengambang (`0 10px 28px rgba(37,99,235,.25)` untuk tombol utama; `0 2px 10px rgba(15,23,42,.05)` untuk kartu biasa).
- Ikon: vektor Material (bukan emoji — emoji hanya placeholder di mockup).
- Target sentuh minimum 44×44dp.

---

## 3. Beranda (dashboard)

Struktur (dari atas ke bawah), mempertahankan referensi captain, direkolor biru:

1. **Bilah atas**: tombol menu (☰) · judul "POSWAROENG" · tombol muat-ulang (⟳) · lonceng notifikasi (titik merah bila ada).
2. **Kartu Laporan Hari Ini** (hero gradien biru): label "Laporan Hari Ini" + lencana "KASIR AKTIF"; dua angka besar **Pendapatan** (dengan indikator ▲% vs kemarin) dan **Profit**; pil kecil "N transaksi · M produk menipis". Angka dipersingkat (Rp 850rb); angka penuh saat disentuh.
3. **Kartu identitas toko**: avatar + nama toko + subjudul "Kasir & Manajemen Toko" + ikon edit.
4. **Grid Menu Utama — 6 kotak** (2 baris × 3), komposisi harian:
   **Produk · Stok · Barang Masuk · Pengeluaran · Laporan · Riwayat**
   - "Satuan" TIDAK jadi kotak sendiri — dilebur ke dalam Produk (atur satuan saat menambah/mengedit produk).
   - Kasir tidak jadi kotak — sudah diwakili tombol TRANSAKSI.
   - Tiap kotak: ikon bergradasi warna + nama + subjudul satu baris.
5. **Tombol TRANSAKSI** besar bergradasi biru di bawah — aksi paling penting selalu dalam jangkauan ibu jari.

---

## 4. Layar kasir

Dibuka dari tombol TRANSAKSI.

- Bilah atas: kembali (←) · "KASIR" · **saklar tampilan (daftar/grid)** · tombol kamera (scan barcode).
- Kolom pencarian pil + baris chip kategori (Semua/Minuman/Sembako/…).
- **Katalog: daftar DAN grid, pengguna bisa mengganti** (keputusan Q3). Default = daftar padat.
  - Daftar padat: thumbnail · nama · sisa stok (warna redup) · harga · tombol tambah (+). Muat banyak SKU, sisa stok terbaca langsung.
  - Grid ubin: ikon/gambar besar · nama · harga. Target sentuh lega.
- **Keranjang menempel di bawah** (bar mengambang): jumlah item · total · tombol BAYAR. Total selalu terlihat.

---

## 5. Multi-satuan (pembeda #1) — keputusan Q4

- **Scan barcode menentukan satuan otomatis** (barcode versi DUS → item masuk sebagai DUS). Pengguna tidak perlu berpikir.
- **Input manual default ke PCS** (satuan eceran paling umum).
- **Chip satuan di item keranjang** untuk koreksi cepat: PCS/BOX/DUS; satuan aktif disorot biru; harga per satuan ikut berubah; ekuivalen PCS ditampilkan kecil ("setara 144 pcs") agar pemilik yakin.
- Tidak ada layar pilih-satuan yang muncul-tutup. 90% transaksi eceran = satu ketukan.
- **Stok lintas satuan: pecah otomatis ke PCS.** Stok fisik disimpan dalam satuan dasar (PCS); jual DUS saat stok DUS "habis" tapi PCS cukup tetap boleh — jangan menolak transaksi karena barang fisik memang ada. Tampilkan keterangan halus, tanpa menghakimi.

Barang masuk: pilih satuan beli (DUS/BOX/PCS) → **pratinjau konversi ditampilkan SEBELUM simpan** ("+288 pcs masuk gudang · 2 DUS = 20 BOX = 288 pcs") + pencatatan hutang supplier (nominal, tempo). Pratinjau ini pengaman utama salah input.

---

## 6. Pembayaran & struk

- Sheet bayar: total besar berwarna, kolom "uang dibayar", **tombol pecahan cepat** (20rb/50rb/100rb/UANG PAS) di atas keypad, keypad angka besar (termasuk 000), kembalian ditonjolkan hijau.
- Selesai → cetak struk ke printer Bluetooth thermal (58/80mm) → kembali otomatis ke layar kasir (siap pembeli berikutnya).
- MVP: tunai. QRIS menyusul sebagai pilihan metode tanpa mengubah layout.
- Struk: header/footer & ukuran kertas dari Pengaturan. Item satuan non-dasar mencantumkan satuan di nama ("Mie Goreng DUS").

---

## 7. Hal yang dikunci sekaligus

- Onboarding: tanpa akun, langsung pakai; satu layar opsional "isi nama toko" yang bisa dilewati.
- Bahasa Indonesia saja untuk MVP (struktur siap i18n).
- Backup/restore: file SQLite via SAF/share (pindah perangkat), sesuai rencana teknis.

---

## 8. Penerjemahan ke Flutter (untuk pekerja implementasi)

- Satu `AppTheme` (light+dark) dari `ColorScheme.fromSeed(seedColor: Color(0xFF2563EB))`; token kustom (gradien, warna positif, radius, bayangan) sebagai `ThemeExtension`.
- `TextTheme` memakai `GoogleFonts.plusJakartaSansTextTheme`.
- Widget dashboard, kartu, chip satuan, keypad dibuat sebagai komponen reusable di `core/widgets/` — jangan copy-paste gaya per layar.
- Semua warna/ukuran ambil dari tema; nol warna hardcode di widget.
