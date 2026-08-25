# POSWaroeng

**Aplikasi stok & kasir untuk warung Indonesia yang paham satuan dus/box/pcs — 100% offline, gratis, tanpa daftar.**

Beli per dus, jual eceran per pcs, tanpa hitung ulang manual. Data tersimpan lokal di HP Anda (SQLite), tidak dikirim ke mana pun.

## Fitur Utama

Sudah jadi:
- **Kasir tunai end-to-end** — cari/scan produk, keranjang, pecahan bayar cepat, kembalian otomatis
- **Beranda** — pendapatan & profit hari ini, indikator stok menipis, 6 menu utama
- **Manajemen produk** — CRUD + kategori + harga beli/jual (rupiah bulat)
- **Struk thermal Bluetooth** 58/80mm (fallback pratinjau di layar)
- **Pengaturan toko & printer**

Menyusul:
- **Multi-satuan bertingkat** (1 DUS = 10 BOX = 100 PCS) dengan barcode & harga per satuan — pembeda #1
- **Barang masuk + hutang supplier**
- **Stok: opname, riwayat mutasi, alert stok minimum**
- **Pengeluaran & laporan tak terbatas** (tanpa watermark)
- **Riwayat transaksi lengkap**, backup/restore file lokal

## Status & Roadmap

| Fase | Isi | Status |
|---|---|---|
| 0 | Fondasi: Flutter + skema DB v1 + CI | ✅ selesai |
| 1 | Kasir MVP end-to-end + struk BT + pengaturan | ✅ selesai |
| 2 | Multi-satuan penuh + stok + scan barcode | 🔜 rencana |
| 3 | Barang masuk + hutang supplier | 🔜 rencana |
| 4 | Pengeluaran + laporan | 🔜 rencana |
| 5 | Struk lanjut + backup/restore + polish | 🔜 rencana |
| 6 | Signed release APK | 🔜 rencana |

## Build & Rilis (CI-only)

Tidak ada build lokal — GitHub Actions satu-satunya verifikator:

1. Push/PR ke `main` → CI menjalankan `flutter analyze` + `flutter test`, lalu build APK debug sebagai artifact.
2. Push tag `v*` → job release menerbitkan APK ke [GitHub Releases](../../releases) otomatis.

## Struktur Repo

```
docs/          PRD, spesifikasi UI/UX, arsitektur teknis, riset pasar
lib/core/      DB (skema+migrasi), tema, format, printing
lib/features/  beranda, kasir, produk, pengaturan, ... (feature-first)
test/unit/     unit test (jalan di CI Linux via sqflite_common_ffi)
.github/workflows/ci.yml   pipeline verify → build-debug → release
```

## Dokumentasi

- [PRD (Product Requirements)](docs/prd.md) — masalah, persona, fitur & user stories, roadmap
- [Spesifikasi UI/UX final](docs/ui-ux-spec.md) — kontrak desain (warna, tipografi, layout)
- [Arsitektur teknis](docs/arsitektur-teknis.md) — struktur proyek, skema DB, CI/CD, printing
- [Riset pasar & kompetitor](docs/riset-pasar.md)
- [AGENTS.md](AGENTS.md) — invarian kunci proyek untuk agent/kontributor

Lisensi: belum ditentukan
