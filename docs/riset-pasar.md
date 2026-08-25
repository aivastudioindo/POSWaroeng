> Snapshot per 2026-08-25. Repo ini adalah sumber kebenaran; dokumen referensi ini disalin utuh dari riset pasar tanpa mengubah substansi.

# Riset Pasar & Kompetitor POSWaroeng

**Aplikasi:** POSWaroeng — kasir + manajemen toko Android untuk warung/UMKM Indonesia
**Posisi produk:** GRATIS penuh, offline murni (tanpa akun, tanpa cloud), data lokal SQLite, distribusi APK via GitHub Releases
**Tanggal riset / akses sumber:** 25 Agustus 2026
**Metode:** web search + kunjungan situs resmi, listing Google Play, situs ulasan, dan blog perbandingan. Fakta ditandai **[V]** = terverifikasi dari sumber resmi (situs/Play Store), **[P]** = persepsi (ulasan pengguna/blog), **[U]** = belum terverifikasi/perlu konfirmasi. Bila sumber bertentangan, keduanya ditampilkan.

> Catatan kurs: konversi USD→IDR memakai ~Rp16.300/USD hanya untuk gambaran skala.

---

## 1. Ringkasan Eksekutif

Pasar aplikasi kasir untuk warung/UMKM Indonesia sudah padat dan matang. Fitur dasar kasir (pencarian produk, hitung total, kembalian, cetak struk thermal Bluetooth, manajemen stok sederhana, laporan harian) sudah menjadi **table-stakes** — hampir semua kompetitor punya, banyak yang gratis. Karena itu, membangun POSWaroeng hanya dengan fitur dasar tidak akan membedakannya.

Tiga temuan terpenting:

1. **Multi-satuan dengan konversi bertingkat (1 DUS = 10 BOX = 100 PCS) + barcode BERBEDA per satuan + harga beli per satuan adalah celah pasar yang nyata.** Dari 10+ aplikasi yang diriset, **tidak satu pun** menawarkan fitur ini secara lengkap dan gratis. Yang paling dekat:
   - Majoo: "multisatuan" **berbayar** (mulai paket Advance ~Rp499rb/outlet/bulan), tetapi barcode-per-satuan dan harga-beli-per-satuan **belum terkonfirmasi [U]**.
   - Kasir Pintar: "multi satuan" (pcs/lusin/kodi) **berbayar** (plugin Business Account), granularitas barcode/harga-beli per satuan **belum terkonfirmasi [U]**.
   - iREAP: hanya lewat "Product Set/BOM" (berbayar, Pro) — mekanisme bundel, bukan konversi bertingkat sejati.
   - Loyverse, Square, Zettle: **tidak ada sama sekali** di tier manapun.
   Ini adalah kandidat diferensiator #1 POSWaroeng, sekaligus kebutuhan riil warung kelontong/grosir yang membeli per dus dan menjual per pcs.

2. **Posisi "gratis penuh + offline murni + tanpa akun + tanpa cloud" hampir unik.** Semua kompetitor arus utama (Qasir, Moka, Majoo, Kasir Pintar, Pawoon, Olsera, iREAP Pro, dan semua pemain global) **mewajibkan registrasi akun dan cloud**. Banyak yang "offline" hanya berarti "bisa transaksi saat internet putus lalu sinkron" — bukan offline murni. Satu-satunya yang benar-benar bisa dipakai tanpa registrasi adalah **iREAP POS Lite** (gratis, offline), tetapi Lite sengaja dipangkas (tanpa multi-payment, tanpa menu pengeluaran, tanpa Product Set/multi-satuan, tanpa laporan web). Jadi kombinasi "gratis penuh TANPA fitur terpangkas + offline murni + tanpa akun" belum ada tandingan langsung.

3. **Pola monetisasi kompetitor menunjukkan peta peluang.** Fitur yang paling sering dikunci di paywall: laporan lanjutan/riwayat panjang, multi-outlet, manajemen karyawan, purchase order/supplier, multi-satuan, mode offline, dan penghilangan watermark/iklan. Karena POSWaroeng gratis penuh, memberikan hal-hal ini secara cuma-cuma langsung menjadi daya tarik akuisisi pengguna — terutama **laporan tak terbatas, PO/supplier, multi-satuan, dan struk tanpa watermark/iklan**.

**Rekomendasi inti:** Jangan menjual POSWaroeng sebagai "kasir gratis" (itu sudah ramai dan lemah). Jual sebagai **"aplikasi stok & kasir grosir-kelontong yang paham satuan (dus/box/pcs), 100% offline, 100% gratis, tanpa daftar, data milik Anda sendiri."** Multi-satuan sejati + privasi/kepemilikan data + zero-friction (langsung pakai tanpa daftar) adalah tiga pilar diferensiasi yang realistis untuk aplikasi gratis-offline.

---

## 2. Peta Kompetitor

### 2a. Aplikasi POS Indonesia

| Aplikasi | Model harga | Offline | Butuh akun/cloud | Segmen | Struk BT 58/80mm | Multi-satuan bertingkat + barcode/harga per satuan |
|---|---|---|---|---|---|---|
| **Qasir** | Freemium. Free (berisi iklan, laporan 30 hari). Pro Rp699rb/th, Pro Plus Rp1,199rb/th [V] | Online & offline, sinkron [V] | Wajib [V] | Mikro/UMKM serba-guna [V] | Ya [V] | Tidak jelas didukung [U] |
| **Moka POS** | Langganan, tanpa free tier. Basic Rp299rb, Pro Rp499rb, Enterprise Rp799rb /outlet/bln [V] | Cloud-sentris; offline bukan andalan [U/P] | Wajib [V] | Retail & F&B, multi-outlet [V] | Ya [V] | Tidak terdokumentasi [U] |
| **Majoo** | Langganan. Starter Rp249rb, Advance Rp499rb, Prime Rp999rb /outlet/bln (excl. PPN) [V] | Order offline semua tier; local server = Prime [V] | Wajib [V] | Luas, up-market (akuntansi/payroll) [V] | Ya (58mm & 80mm) [V] | **Multisatuan BERBAYAR (Advance+)** [V]; barcode/harga per satuan [U] |
| **Kasir Pintar** | Freemium. Free (watermark struk, maks 1.000 produk). Pro Rp666rb/th + plugin berbayar [V] | Butuh plugin POS Offline berbayar + PC [V] | Wajib [V] | UMKM + banyak vertikal [V] | Ya (multi-printer) [V] | **Multi-satuan (pcs/lusin/kodi) BERBAYAR (plugin)** [V]; barcode/harga per satuan [U] |
| **iREAP POS** | Lite GRATIS (offline, tanpa daftar). Pro Rp99rb/bln–Rp500rb/th per device [V] | Lite offline murni; Pro hybrid+sinkron [V] | **Lite: TIDAK** / Pro: wajib [V] | Retail/distributor/franchise [V] | Ya (30+ model) [V] | Parsial via Product Set/BOM (Pro, berbayar); bukan konversi bertingkat sejati [V] |
| **Olsera** | Trial 14 hari; langganan tahunan Rp1,29jt–2,69jt/th [V] | Ya, offline+sinkron [V] | Wajib [V] | UMKM F&B + retail, multi-cabang [V] | Ya [V] | Ada konsep UOM & harga modal, konversi bertingkat + barcode/harga per satuan [U] |
| **Pawoon** | Freemium. Free (dibatasi ~7 transaksi/hari, ~50 produk, ada iklan). Pro Rp299rb/outlet/bln [V] | Ya, offline+sinkron [V] | Wajib [V] | UMKM F&B/retail, franchise [V] | Ya (thermal & dot matrix) [V] | Tidak diiklankan [U] |
| **ESB (ESB POS)** | Basic mulai Rp0; Advanced mulai Rp499rb/bln; Enterprise custom [V] | Ya, offline+sinkron [V] | Wajib [V] | **F&B/kuliner saja** [V] | Ya (implisit) [V/U] | Tidak untuk retail [U] |
| **BukuWarung** | Gratis (monetisasi via PPOB/QRIS/pinjaman) [V] | Cloud-dependent, offline tidak diiklankan [U] | Wajib (KYC berat) [V] | Mikro/fintech-pembukuan [V] | Ya (struk WA/BT) [V] | Tidak ada [U] |
| **BukuKas/Lummo** | — | — | — | Sudah pivot ke LummoSHOP; app pembukuan konsumen ditinggalkan [P/U] | — | Efektif bukan opsi POS aktif 2025/2026 [P/U] |

### 2b. Aplikasi POS Global (pembanding)

| Aplikasi | Model harga | Offline | Butuh akun/cloud | Segmen | Struk BT 58/80mm | Multi-satuan bertingkat | Bisa dipakai di Indonesia? |
|---|---|---|---|---|---|---|---|
| **Loyverse** | Freemium. POS inti GRATIS (unlimited device). Add-on: riwayat unlimited $9/bln, karyawan $5/karyawan, advanced inventory $25/bln [V] | Ya, toleran koneksi lemah, sinkron [V] | Wajib [V] | Ritel/kafe/grocery kecil global, ada Bahasa Indonesia [V] | **Ya** [V] | **Tidak ada** di tier manapun [V/P] | App ya; **pembayaran kartu tidak tersedia** (SumUp/Zettle tak ada di ID) [V] |
| **Square POS** | Free + biaya proses. Tier berbayar (Plus/Premium) [V] | Terbatas (mode offline sementara) [P] | Wajib [V] | Ritel/F&B/jasa kecil-menengah [V] | Terbatas (cenderung LAN/USB) [P] | Tidak native [P] | **Tidak** — Square tidak beroperasi di Indonesia [V] |
| **Zettle by PayPal** | App gratis + biaya proses + hardware [V] | Terbatas [P] | Wajib [V] | Mikro/pedagang keliling, payments-first [V] | Terbatas/model-dependent [P] | Tidak ada [P] | **Tidak** — tak tersedia di Indonesia [V] |
| **Lightspeed Retail** | Langganan, tanpa free tier. ~$89–289/bln [P] | Terbatas [P] | Wajib [V] | Ritel SMB-menengah mapan [P] | Ya (umumnya jaringan) [P] | Parsial (terbaik di grup ini: unit cost, case/pack) [P] | Software ya; pembayaran ID tidak native [P] |
| **Shopify POS** | Langganan plan Shopify ($25–399/bln) + POS Pro +$89/bln/lokasi [V] | Sangat terbatas [P] | Wajib [V] | Omnichannel retailer (online+offline) [V] | Ya (model-dependent) [P] | Tidak native (butuh app berbayar) [P] | Software ya; **Shopify Payments tak tersedia di ID** [V] |

**Sumber (semua diakses 25 Agustus 2026):**
- Qasir: https://www.qasir.id/qasir-pro , https://www.qasir.id/fitur-tambahan , https://play.google.com/store/apps/details?id=com.innovecto.etalastic
- Moka: https://www.mokapos.com/harga , https://www.mokapos.com/jualan-offline/manajemen-stok , https://play.google.com/store/apps/details?id=com.mokapos.android
- Majoo: https://majoo.id/harga , https://play.google.com/store/apps/details?id=com.klopos
- Kasir Pintar: https://kasirpintar.co.id/harga , https://kasirpintar.co.id/aplikasi-bisnis , https://kasirpintar.co.id/pos_offline
- iREAP: https://www.ireappos.com/en/ , https://www.ireappos.com/en/how-to-ireappos-pro/how-to-use-uom-in-sales-ireappos-pro.php , https://play.google.com/store/apps/details?id=com.sterling.ireappro
- Olsera: https://www.olsera.com/id/pos , https://www.olsera.com/en/pricing
- Pawoon: https://www.pawoon.com/harga/ , https://www.pawoon.com/aplikasi-kasir/
- ESB: https://esb.id/ , https://esb.id/id/pricing
- BukuWarung: https://bukuwarung.com/ , https://play.google.com/store/apps/details?id=com.bukuwarung
- Loyverse: https://loyverse.com/pricing , https://loyverse.com/features , https://loyverse.com/advanced-inventory , https://loyverse.town/
- Square: https://squareup.com/us/en/point-of-sale/pricing
- Zettle: https://www.zettle.com/
- Lightspeed: https://www.lightspeedhq.com/pos/retail/pricing (halaman resmi memblokir fetch otomatis; harga dari sumber pihak ketiga 2025/2026 — tandai [P], verifikasi ulang sebelum publikasi)
- Shopify: https://www.shopify.com/pos/pricing

---

## 3. Analisis Fitur Baseline: Table-Stakes vs Jarang/Berbayar

Menilai setiap fitur baseline POSWaroeng terhadap kompetitor.

### 3a. Sudah TABLE-STAKES (dimiliki hampir semua kompetitor — bukan diferensiator)

| Fitur baseline | Status | Bukti |
|---|---|---|
| Kasir: pencarian produk, total, bayar & kembalian, harga jual per satuan | Table-stakes | Ada di semua aplikasi (Qasir, Moka, Majoo, Kasir Pintar, Loyverse, dll.) [V] |
| Produk: kode, barcode, kategori, harga beli/jual, stok minimum | Table-stakes | Standar di semua; low-stock alert bahkan gratis di Loyverse [V] |
| Stok bertambah/berkurang + riwayat perubahan | Table-stakes | Qasir (stock opname & history, free), Loyverse (free stock tracking), Kasir Pintar (FIFO/LIFO/Average) [V] |
| Pengeluaran/biaya operasional + rekap harian | Table-stakes (tapi lihat catatan) | Umum di modul keuangan; Kasir Pintar cash in/out, BukuWarung pembukuan. Catatan: di iREAP menu pengeluaran hanya di Pro [V] |
| Laporan penjualan/stok/transaksi | Table-stakes | Semua punya; TAPI kedalaman & rentang waktu sering dibatasi (lihat §5) [V] |
| Struk: info toko, footer, 58/80mm, printer thermal Bluetooth | Table-stakes | Qasir, Moka, Majoo, Kasir Pintar, Pawoon, iREAP, Loyverse semua dukung BT thermal [V] |
| Barang masuk / pembelian dari supplier | Table-stakes (sering berbayar) | Moka (PO), Majoo (Prime), Kasir Pintar (supplier+AI invoicing), iREAP (goods receipt). Di beberapa app terkunci tier atas [V] |

**Implikasi:** Semua fitur di atas WAJIB ada agar POSWaroeng dianggap layak, tetapi tidak satupun akan membuat pengguna berpindah. Ini "tiket masuk", bukan alasan memilih.

### 3b. JARANG / DITAWARKAN BERBAYAR (kandidat diferensiator)

| Fitur baseline | Status di pasar | Bukti |
|---|---|---|
| **Multi-satuan konversi bertingkat (DUS=BOX=PCS) + barcode BEDA per satuan + harga beli per satuan** | **LANGKA & selalu berbayar/parsial** | Tidak ada satupun yang menyediakan lengkap+gratis. Majoo: multisatuan berbayar Advance+ [V], barcode/harga per satuan [U]. Kasir Pintar: multi satuan plugin berbayar [V]. iREAP: hanya Product Set/BOM (Pro) — bukan konversi bertingkat sejati [V]. Loyverse/Square/Zettle: tidak ada [V]. **Ini celah #1.** |
| **Pencatatan hutang (ke supplier) saat barang masuk** | Jarang menyatu dengan pembelian | Kebanyakan pisah antara PO dan buku hutang. BukuWarung kuat di utang-piutang tapi bukan POS penuh & online [V] |
| **Hutang/kasbon pelanggan** | Ada tapi tak merata | Qasir Catat Kasbon (gratis) [V], Kasir Pintar (plugin Desktop) [V], Moka lemah/absen [U], Loyverse tidak fokus |
| **Offline murni tanpa akun/cloud** | Sangat langka | Hanya iREAP Lite yang benar-benar tanpa daftar [V]; semua lainnya wajib akun. "Offline" kompetitor lain = offline-lalu-sinkron, tetap butuh akun cloud [V] |
| **Backup/restore DB lokal untuk pindah perangkat** | Jarang diekspos ke pengguna | Kompetitor cloud memakai sinkron server (bukan file lokal). Backup file SQLite yang dikontrol pengguna adalah pendekatan berbeda yang cocok untuk model offline/no-cloud [P] |

### 3c. Penilaian posisi "gratis penuh + offline + tanpa akun"

- **Gratis penuh:** Loyverse gratis untuk POS inti, tapi mengunci advanced inventory ($25/bln), riwayat panjang ($9/bln), karyawan ($5). Qasir/Kasir Pintar gratis tapi dengan iklan, watermark, batas produk/laporan. iREAP Lite gratis tapi terpangkas. **POSWaroeng gratis-tanpa-batas adalah nilai jual nyata.** [V]
- **Offline murni:** Mayoritas kompetitor cloud-first. Offline murni + data lokal SQLite = keunggulan untuk warung dengan internet buruk/tanpa internet. [V]
- **Tanpa akun:** Hampir semua wajib registrasi (beberapa dengan KYC berat spt BukuWarung). Zero-friction "buka-langsung-pakai" adalah keunggulan akuisisi & privasi. [V]

**Kesimpulan §3:** Fitur baseline POSWaroeng sebagian besar table-stakes. Yang membedakan hanyalah **(a) multi-satuan bertingkat lengkap, (b) kombinasi gratis-penuh+offline+tanpa-akun, (c) kepemilikan data via backup SQLite lokal.** Tiga hal ini harus jadi fokus pemasaran & pengembangan.

---

## 4. Celah Diferensiasi (BAGIAN TERPENTING) — Terurut Impact vs Effort

Daftar terurut berdasarkan rasio dampak-terhadap-usaha untuk aplikasi GRATIS-OFFLINE. Skala: Impact/Effort = Tinggi/Sedang/Rendah. Setiap item disertai bukti.

### Prioritas 1 — Multi-satuan bertingkat sejati (DUS→BOX→PCS) dengan barcode & harga beli per satuan
- **Impact: SANGAT TINGGI · Effort: SEDANG**
- **Bukti celah:** Tidak ada kompetitor yang menyediakannya lengkap+gratis. Majoo & Kasir Pintar menaruhnya di balik paywall; barcode-per-satuan & harga-beli-per-satuan bahkan tak terkonfirmasi [V/U]. iREAP hanya punya bundel BOM (Pro) [V]. Loyverse/Square/Zettle nihil [V]. Komunitas Loyverse eksplisit meminta fitur ini dan hanya diberi workaround [P].
- **Kenapa realistis untuk gratis-offline:** Murni logika data lokal (tabel konversi satuan, mapping barcode→satuan, harga beli per level). Tidak butuh cloud/pembayaran. Ini justru kekuatan alami SQLite lokal.
- **Nilai bagi warung:** Warung kelontong beli per dus/karton, jual eceran per pcs. Otomatisasi konversi menghilangkan hitung ulang manual & kesalahan stok — pain point nyata. **Jadikan headline produk.**

### Prioritas 2 — Barang masuk + pencatatan hutang supplier yang menyatu, offline
- **Impact: TINGGI · Effort: SEDANG**
- **Bukti celah:** PO/supplier umumnya dikunci tier atas (Moka, Majoo Prime, Loyverse advanced inventory $25/bln) [V]. Buku hutang supplier yang menyatu dengan pembelian jarang; BukuWarung kuat di hutang tapi bukan POS penuh & wajib online/KYC [V].
- **Realistis:** Data lokal murni. Menggabungkan "barang masuk → tambah stok (dengan konversi satuan) → catat hutang ke supplier → jadwal bayar" dalam satu alur adalah nilai besar tanpa biaya server.
- **Nilai:** Warung mengelola modal & utang dagang; fitur ini gratis di POSWaroeng vs berbayar di lain.

### Prioritas 3 — Laporan lengkap tanpa batas waktu & tanpa watermark, gratis
- **Impact: TINGGI · Effort: RENDAH**
- **Bukti celah:** Riwayat/laporan justru fitur monetisasi paling umum: Loyverse batasi ~90 hari (unlimited = $9/bln) [V]; Qasir free hanya 30 hari [V]; Kasir Pintar free hanya tampilkan 1.000 data terakhir + watermark struk [V]. 
- **Realistis:** Data sudah di SQLite; query laporan sepanjang waktu = usaha rendah.
- **Nilai:** "Semua laporan, selamanya, gratis, tanpa watermark" langsung mengalahkan tier gratis kompetitor.

### Prioritas 4 — Zero-friction: buka langsung pakai tanpa registrasi/KYC + privasi/kepemilikan data
- **Impact: TINGGI · Effort: RENDAH**
- **Bukti celah:** Hampir semua wajib akun/cloud; BukuWarung bahkan KYC berat (KTP+selfie) [V/P]; registrasi Moka dikeluhkan "seperti buka rekening" [P]. Beberapa app free berbagi data ke pihak ketiga & tidak terenkripsi (Qasir, Moka data-safety Play) [V].
- **Realistis:** Justru inti arsitektur no-cloud POSWaroeng; effort nyaris nol — tinggal ditonjolkan sebagai fitur ("data 100% di HP Anda, tidak dikirim ke mana pun").
- **Nilai:** Menghilangkan hambatan onboarding + menjawab kekhawatiran privasi/biaya data.

### Prioritas 5 — Backup/restore file SQLite yang dikontrol penuh pengguna (pindah perangkat)
- **Impact: SEDANG · Effort: RENDAH**
- **Bukti celah:** Kompetitor cloud "mengunci" data di server mereka; pindah perangkat = login akun. Backup file lokal yang bisa dibagikan (ke Google Drive/USB/WA) memberi kepemilikan penuh & bebas biaya langganan [P].
- **Realistis:** Ekspor/impor file .db + validasi versi skema.
- **Nilai:** Menepis kekhawatiran "kalau HP rusak/data hilang" tanpa memaksa cloud.

### Prioritas 6 — Struk & label yang fleksibel + cetak label barcode per satuan
- **Impact: SEDANG · Effort: SEDANG**
- **Bukti celah:** Cetak label barcode sering fitur tier atas (Olsera) [V]. Karena POSWaroeng punya barcode berbeda per satuan, mencetak label per satuan (mis. barcode BOX) adalah pelengkap alami multi-satuan.
- **Realistis:** Memakai printer thermal yang sama; menambah template label.

### Prioritas 7 — Multi-user/peran sederhana secara lokal (tanpa cloud)
- **Impact: RENDAH-SEDANG · Effort: SEDANG**
- **Bukti celah:** Manajemen karyawan hampir selalu berbayar (Loyverse $5/karyawan, Moka slot berbayar, Majoo payroll tier atas) [V].
- **Realistis TAPI hati-hati:** PIN kasir lokal sederhana bisa; audit multi-perangkat real-time bertentangan dengan model offline single-device. Jaga tetap ringan agar tidak merusak positioning.

**Ringkasan urutan rekomendasi:** P1 Multi-satuan → P2 Barang masuk+hutang supplier → P3 Laporan gratis tanpa batas → P4 Zero-friction/privasi → P5 Backup SQLite → P6 Label barcode per satuan → P7 PIN kasir lokal.

---

## 5. Pola Monetisasi Kompetitor (Peluang Akuisisi bagi POSWaroeng)

Fitur yang paling sering dikunci di paywall — karena POSWaroeng gratis, memberikannya cuma-cuma = umpan akuisisi.

| Fitur yang dikunci | Di mana dikunci | Bukti |
|---|---|---|
| Riwayat/laporan panjang & lanjutan | Loyverse (unlimited $9/bln), Qasir (free 30 hari), Kasir Pintar (free 1.000 data) | [V] |
| Multi-outlet / multi-cabang | Pawoon (Pro), Moka (per outlet), Majoo (per outlet) | [V] |
| Manajemen karyawan/shift/payroll | Loyverse ($5/karyawan), Moka (slot berbayar), Majoo (payroll Prime) | [V] |
| Advanced inventory / PO / supplier / valuasi | Loyverse ($25/bln), Moka (PO), Majoo (Prime), Shopify (POS Pro $89/bln) | [V] |
| **Multi-satuan** | Majoo (Advance+), Kasir Pintar (plugin) | [V] |
| Mode offline penuh | Kasir Pintar (plugin POS Offline berbayar), Majoo (local server Prime) | [V] |
| Hilangkan watermark struk / iklan | Kasir Pintar (watermark di free), Qasir & Pawoon (iklan di free) | [V] |
| Toko online / integrasi marketplace | Qasir (Pro), Majoo (add-on Rp499rb), Olsera (tier atas) | [V] |
| Harga grosir / bundel produk | Qasir (fitur tambahan satuan berbayar), Majoo (Grosir = Prime) | [V] |

**Strategi:** POSWaroeng tidak perlu meniru semua. Fokus pada yang berdampak untuk warung & realistis offline: **laporan tak terbatas, PO/supplier+hutang, multi-satuan, tanpa watermark/iklan, harga grosir/bundel.** Sisanya (multi-outlet real-time, payroll, marketplace) bertentangan dengan model offline-single-device dan bisa diabaikan tanpa kehilangan segmen inti.

---

## 6. Rekomendasi Akhir

1. **Reposisi pesan produk.** Bukan "kasir gratis" (pasar jenuh), melainkan **"aplikasi stok & kasir grosir-kelontong yang paham satuan (dus/box/pcs), 100% offline, 100% gratis, tanpa daftar, data milik Anda."**
2. **Jadikan multi-satuan bertingkat (barcode + harga beli per satuan) fitur unggulan #1** — ini satu-satunya celah yang benar-benar kosong+gratis di seluruh pasar dan cocok dengan kekuatan SQLite lokal.
3. **Gratiskan yang biasanya berbayar:** laporan tak terbatas tanpa watermark, PO/supplier + buku hutang, harga grosir/bundel.
4. **Tonjolkan zero-friction & privasi** sebagai fitur, bukan sekadar keterbatasan: langsung pakai tanpa akun, data tidak dikirim ke mana pun, backup file milik pengguna.
5. **Hindari perlombaan fitur cloud** (multi-outlet real-time, payroll, marketplace) — bertentangan dengan model offline dan menguras fokus.
6. **Kompetitor yang paling perlu dikalahkan langsung: Loyverse** (gratis, Bahasa Indonesia, BT thermal, offline-toleran) dan **iREAP Lite** (satu-satunya gratis tanpa daftar). Kalahkan keduanya lewat: multi-satuan sejati, PO/supplier gratis, dan gratis-penuh-tanpa-pangkas.

---

## 7. Catatan Metodologi & Keterbatasan

- Semua sumber diakses **25 Agustus 2026**. Harga & paket kompetitor dapat berubah sewaktu-waktu; angka ditandai [V] berasal dari halaman resmi/Play Store pada tanggal tersebut.
- Item bertanda **[U]** perlu konfirmasi via trial/help-center aplikasi sebelum dikutip sebagai fakta final — khususnya mekanik "multisatuan" (apakah mencakup barcode berbeda per satuan + harga beli per satuan + pengurangan stok hierarkis otomatis) di Majoo, Kasir Pintar, dan Olsera.
- Konflik sumber yang tercatat: batas transaksi free-tier Pawoon (halaman harga "7 transaksi/hari" vs respons ulasan "500/bulan") — keduanya ditampilkan.
- Harga Lightspeed berasal dari sumber pihak ketiga (halaman resmi memblokir pengambilan otomatis) — verifikasi ulang sebelum publikasi.
- Status BukuKas/Lummo (penutupan app pembukuan konsumen, pivot LummoSHOP) berasal dari sumber sekunder/berpagar bayar — tandai [U], konfirmasi via Tech in Asia/DealStreetAsia bila akan dikutip.
