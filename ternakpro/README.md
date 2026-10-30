# 🐂 TernakPro — Farm Intelligence OS

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50)](#)
[![Theme](https://img.shields.io/badge/Theme-Dark%20Mode%20%28Emerald%29-10B981)](#)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **TernakPro** adalah platform sistem operasi peternakan cerdas (*Farm Intelligence OS*) yang dirancang khusus untuk manajemen peternakan sapi potong (*beef cattle feedlot*). Sistem ini mengintegrasikan pemantauan performa biologis ternak, akuntansi biaya HPP individual per ekor sapi, manajemen rekam medis digital, hingga estimasi bobot berbasis computer vision.

---

## 📑 Daftar Isi
- [Latar Belakang & Masalah](#-latar-belakang--masalah)
- [Fitur Utama](#-fitur-utama)
  - [1. Beranda & Executive Dashboard](#1-beranda--executive-dashboard)
  - [2. Manajemen Data Ternak Kandang](#2-manajemen-data-ternak-kandang)
  - [3. Detail Sapi & Kalkulasi Finansial Individual](#3-detail-sapi--kalkulasi-finansial-individual)
  - [4. Keuangan & Pencatatan Kilat (Quick Expense)](#4-keuangan--pencatatan-kilat-quick-expense)
  - [5. Rekam Medis Digital & Resep Mantri](#5-rekam-medis-digital--resep-mantri)
  - [6. AI Vision Scanner & Estimasi Bobot](#6-ai-vision-scanner--estimasi-bobot)
  - [7. Instrumen Evaluasi Riset (SUS)](#7-instrumen-evaluasi-riset-sus)
- [Rumus Finansial & Biologis](#-rumus-finansial--biologis)
- [Struktur Direktori Proyek](#-struktur-direktori-proyek)
- [Tech Stack & Pustaka](#-tech-stack--pustaka)
- [Panduan Instalasi & Menjalankan Aplikasi](#-panduan-instalasi--menjalankan-aplikasi)
- [Kontribusi & Lisensi](#-kontribusi--lisensi)

---

## 💡 Latar Belakang & Masalah

Pada peternakan sapi potong tradisional maupun semi-intensif:
1. **Biaya HPP Sapi Campur Aduk**: Peternak sulit mengetahui berapa modal riil yang dihabiskan untuk satu ekor sapi tertentu (pembelian bakalan + pakan konsentrat + obat).
2. **Pencatatan Medis Tercecer**: Riwayat injeksi vaksin, vitamin, dan resep mantri sering kali hanya dicatat di kertas atau diingat-ingat.
3. **Keterlambatan Deteksi Stunting**: Sapi yang mengalami pertumbuhan lambat (*stunted*) terlambat diketahui karena tidak ada monitoring metrik ADG (*Average Daily Gain*) secara berkala.
4. **Pencatatan Lapangan Tidak Praktis**: Peternak butuh input cepat saat membeli pakan atau obat di kandang tanpa navigasi menu yang rumit.

**TernakPro** menjawab seluruh tantangan tersebut melalui satu aplikasi terpadu dengan tampilan antarmuka *Dark Theme* berkontras tinggi yang nyaman digunakan di bawah terik matahari kandang.

---

## 🌟 Fitur Utama

### 1. Beranda & Executive Dashboard
- **Populasi & Kesehatan Real-time**: Ringkasan jumlah sapi hidup, sapi sehat, dalam pemulihan, dan sapi yang membutuhkan perhatian khusus (*Stunted / Critical*).
- **Executive Financial Banner**: Estimasi nilai pasar bobot hidup (*Live Market Value*), total modal HPP kandang, dan estimasi potensi keuntungan bersih (*Net Profit Margin*).
- **Sapi Prioritas Perhatian**: Algoritma deteksi otomatis untuk menampilkan sapi yang mengalami defisit pakan atau penurunan ADG.
- **Feed Aktivitas Lapangan**: Log kronologis aktivitas terkini (penimbangan, pakan pagi, penugasan mantri).

### 2. Manajemen Data Ternak Kandang
- **Filter Multi-Level**:
  - Filter Status Kesehatan: *Semua*, *Sehat*, *Dalam Pemulihan*, dan *Stunted*.
  - Filter Ras Ternak: *Semua Ras*, *Madura*, *Limosin*, *Simental*, dan *Peranakan Ongole (PO)*.
  - Pengurutan: *Masuk Terbaru*, *Bobot Tertinggi*, dan *ADG Tertinggi*.
- **Pencarian Cerdas**: Pencarian instan berdasarkan nomor eartag (`#012`), ras sapi, maupun nama blok pen kandang, dilengkapi shortcut keyboard `⌘ K`.
- **Kartu Ternak Komprehensif**:
  - Status kesehatan visual dengan avatar berkode warna (Hijau, Amber, Merah).
  - Informasi penempatan pen, kelompok umur, ransum pakan harian, dan lama pemeliharaan (*days in feedlot*).
  - Indikator metrik: Bobot terkini (kg), pertambahan bobot (*weight gain*), dan nilai ADG harian.
  - Tombol aksi terarah: **[Timbang Ulang]**, **[Cek Nutrisi]**, atau **[Catatan Medis]**.

### 3. Detail Sapi & Kalkulasi Finansial Individual
- **Grafik Tren Bobot Interaktif**: Kurva riwayat penimbangan bobot menggunakan `fl_chart`.
- **Kalkulator HPP Individual**:
  - Breakdown biaya per ekor: Pembelian bakalan, pakan konsentrat, vitamin & medis, serta biaya insidental.
  - Perhitungan otomatis Margin Keuntungan (%).
  - Titik Impas Penjualan (*BEP / kg bobot hidup*) untuk memastikan peternak tidak menjual di bawah harga modal.
- **Riwayat Transaksi & Klinis Sapi Terkait**: Integrasi langsung dengan modul rekam medis dan pembukuan.

### 4. Keuangan & Pencatatan Kilat (Quick Expense)
- **Ringkasan Finansial Farm**: Total pengeluaran kandang dan rata-rata HPP per ekor.
- **Visualisasi Pie Chart**: Distribusi alokasi biaya pakan, bakalan, dan obat-obatan.
- **Floating Button Input Kilat (⚡)**: Modal bottom sheet cepat untuk mencatat pengeluaran spontan di lapangan tanpa meninggalkan layar aktif.

### 5. Rekam Medis Digital & Resep Mantri
- **4 Kartu Metrik Klinis**: Total Tindakan, Resep Mantri Hewan, Rawat Mandiri/Herbal, dan Jadwal Kontrol.
- **Segregasi Jenis Penanganan**:
  - **Resep Mantri**: Penanganan medis dokter hewan / mantri (injeksi antibiotik, ivomec, vaksinasi, nomor resep).
  - **Mandiri / Herbal**: Pengobatan tradisional pekerja kandang (jamu empon-empon, salep kuku retak, ramuan nafsu makan).
- **Kartu Catatan Klinis 3-Kolom**: Memisahkan secara presisi antara *Tindakan Dilakukan*, *Obat/Terapi yang Diberikan*, dan *Petugas Medis Hewan*.
- **Badge Tindak Lanjut**: Status tindak lanjut (*Membaik / Selesai*, *Kontrol 3 Hari*, *Kontrol Ulang Terjadwal*) dan catatan evaluasi khusus.

### 6. AI Vision Scanner & Estimasi Bobot
- Simulasi antarmuka pemindai kamera augmented/computer vision untuk estimasi bobot sapi secara digital tanpa stres timbangan mekanik.
- Panduan pandangan (*bounding box & depth target*) untuk akurasi penaksiran visual.

### 7. Instrumen Evaluasi Riset (SUS)
- Modul kuesioner terintegrasi **System Usability Scale (SUS)** dengan 10 pertanyaan standar metodologi riset human-computer interaction (HCI).
- Kalkulasi otomatis konversi skor 0–100, penentuan *Grade Scale (A/B/C/D/F)*, serta rekomendasi kelayakan *Acceptability Range*.

---

## 📐 Rumus Finansial & Biologis

Sistem TernakPro menggunakan acuan formula standar industri peternakan sapi potong:

$$
\text{Days in Feedlot} = \text{Tanggal Hari Ini} - \text{Tanggal Masuk}
$$

$$
\text{ADG (Average Daily Gain)} = \frac{\text{Bobot Terakhir (kg)} - \text{Bobot Awal (kg)}}{\text{Days in Feedlot}}
$$

$$
\text{HPP Sapi}_i = \text{Harga Bakalan}_i + \sum \text{Pakan}_i + \sum \text{Medis}_i + \sum \text{Insidental}_i
$$

$$
\text{Valuasi Pasar} = \text{Bobot Terakhir (kg)} \times \text{Harga Pasar Hidup per kg}
$$

$$
\text{BEP per kg} = \frac{\text{Total HPP Sapi}_i}{\text{Bobot Terakhir (kg)}}
$$

---

## 📁 Struktur Direktori Proyek

```plaintext
ternakpro/
├── android/                   # Konfigurasi native Android
├── ios/                       # Konfigurasi native iOS
├── web/                       # Konfigurasi PWA / Web Flutter
├── windows/                   # Konfigurasi native Windows desktop
├── lib/
│   ├── main.dart              # Entry point aplikasi & inisialisasi lokal ID
│   ├── core/
│   │   └── theme.dart         # Sistem tema warna gelap (AppColors & AppTheme)
│   ├── data/
│   │   └── mock_data.dart     # Mock database reaktif (ChangeNotifier), logika HPP & filter
│   ├── models/
│   │   └── cattle.dart        # Model data: Cattle, MedicalRecord, Transaction, Activity
│   └── screens/
│       ├── splash_screen.dart           # Layar pembuka & animasi inisialisasi
│       ├── main_navigation_screen.dart  # Shell navigasi bawah 5 tab & FAB kilat
│       ├── home_screen.dart             # Beranda & dashboard eksekutif
│       ├── cattle_screen.dart           # Modul Data Ternak Kandang
│       ├── cattle_detail_screen.dart    # Detail sapi, grafik timbang & HPP individual
│       ├── finance_screen.dart          # Modul Keuangan & pie chart biaya
│       ├── medical_screen.dart          # Modul Rekam Medis Digital
│       ├── scanner_screen.dart          # Pemindai AI estimasi bobot visual
│       ├── quick_expense_modal.dart     # Bottom sheet modal input kilat
│       └── sus_evaluation_screen.dart   # Modul instrumen evaluasi usability SUS
└── pubspec.yaml               # Metadata dependensi paket
```

---

## 🛠️ Tech Stack & Pustaka

| Komponen | Teknologi | Keterangan |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (SDK ^3.11.0) | Cross-platform framework |
| **Language** | [Dart](https://dart.dev) | Object-oriented typed language |
| **Typography** | `google_fonts: ^8.2.1` | Font *Plus Jakarta Sans* |
| **Visualisasi Data** | `fl_chart: ^1.2.0` | Grafik garis tren bobot & pie chart pengeluaran |
| **Format Internasional** | `intl: ^0.20.3` | Format tanggal Indonesia (`id_ID`) dan mata uang Rupiah (`Rp`) |
| **Iconography** | `cupertino_icons` & `material_icons` | Ikon status, medis, dan navigasi |
| **State Management** | Native `ChangeNotifier` + `ListenableBuilder` | Manajemen status reaktif tanpa overhead eksternal |

---

## 🚀 Panduan Instalasi & Menjalankan Aplikasi

### Prasyarat
- Flutter SDK (versi >= 3.24.0) terpasang di sistem ([Panduan Unduh Flutter](https://docs.flutter.dev/get-started/install)).
- Android Studio, VS Code, atau IDE yang mendukung ekstensi Flutter/Dart.

### Langkah Menjalankan

1. **Clone repository ini**:
   ```bash
   git clone https://github.com/username/ternakpro.git
   cd ternakpro
   ```

2. **Unduh seluruh dependensi**:
   ```bash
   flutter pub get
   ```

3. **Verifikasi analisis kode (pastikan tidak ada error)**:
   ```bash
   flutter analyze
   ```

4. **Jalankan aplikasi**:
   - Untuk emulator Android / Device fisik:
     ```bash
     flutter run
     ```
   - Untuk browser Chrome (Web):
     ```bash
     flutter run -d chrome
     ```
   - Untuk Windows Desktop:
     ```bash
     flutter run -d windows
     ```

---

## 👥 Kontributor & Riset
Dikembangkan sebagai bagian dari riset inovasi digitalisasi manajemen peternakan sapi potong dan agritech modern.

## 📄 Lisensi
Didistribusikan di bawah lisensi **MIT License**. Lihat berkas `LICENSE` untuk informasi lebih lanjut.
