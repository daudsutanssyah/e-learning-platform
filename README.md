# Simple E-Learning Platform (Student Side)

[![Flutter](https://img.shields.io/badge/Flutter-3.50.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.14.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod%203.5.0-2D3748)](https://riverpod.dev)
[![GoRouter](https://img.shields.io/badge/Router-GoRouter%2018.1.4-4A5568)](https://pub.dev/packages/go_router)
[![Supabase](https://img.shields.io/badge/Backend-Supabase%20PostgreSQL-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Video Player](https://img.shields.io/badge/Player-Video%20Player%20%26%20Chewie-FF6F00)](https://pub.dev/packages/chewie)
[![Design System](https://img.shields.io/badge/UI-Material%20Design%203-6750A4)](https://m3.material.io)

Aplikasi mobile pembelajaran interaktif (*Simple E-Learning Platform*) untuk sisi siswa (*student side*) yang dibangun menggunakan **Flutter** dan **Dart 3** dengan arsitektur **Feature-First Clean Architecture**, **Riverpod**, **GoRouter**, dan basis data cloud **Supabase PostgreSQL**. Aplikasi menghadirkan pengalaman belajar yang mulus dengan katalog kursus adaptif, silabus terstruktur, kartu kontekstual kelas aktif 3 status, filter progres belajar, pemutar video native Chewie dengan manajemen siklus hidup ketat (*anti-memory leak* & *auto-pause* saat latar belakang), serta transisi splash screen elegan dengan *background preloading* otomatis.

---

## Fitur Utama

- 🎓 **Katalog Kursus Responsif:** Layout adaptif 1 kolom (ponsel) dan 2 kolom (tablet/desktop) dengan metadata lengkap (thumbnail 16:9, label kategori, tingkat kesulitan, instruktur, jumlah materi, dan total durasi) serta fitur *Pull-to-Refresh*.
- 📊 **Kartu Kontekstual Kelas Aktif (`LearningSummaryCard`):** Menggantikan statistik agregat kaku dengan kartu dinamis 3 status (*Cold Start*, *Kelas Aktif* dengan progres persentase riil dan tombol "Lanjutkan Belajar", serta *Kelas Tuntas* dengan rekomendasi kursus lanjutan).
- 🏷️ **Filter Status Belajar Interaktif (`CourseFilterBar`):** Pengelompokan kursus secara real-time berdasarkan status belajar (*Semua*, *Belum Dimulai*, *Sedang Dipelajari*, *Selesai*).
- 🎬 **Pemutar Video Native Chewie (`LessonPlayerScreen`):** Pemutaran video berakselerasi perangkat keras (MP4/HLS), kontrol gestur intuitif, pencegahan *race conditions* via `_initToken`, *auto-pause* saat aplikasi di-minimize, dan *auto-advance* materi berikutnya saat video berakhir.
- ✨ **Shimmer Skeleton Loading Murni:** Skeleton animasi kustom tanpa dependensi pihak ketiga, dijalankan menggunakan 1 `AnimationController` bersama (*zero layout shift*).
- 🚀 **Seamless Preload Splash Screen:** Dual-stage splash (Native Android 12 + Animasi Lottie) yang memuat data kursus di latar belakang (*background preloading*) sehingga saat masuk katalog utama, data langsung tampil instan tanpa jeda loading.

---

## Requirements

Pastikan perangkat pengembangan Anda memenuhi persyaratan berikut:

- **Flutter SDK:** Version `3.50.0` (channel stable) atau lebih tinggi
- **Dart SDK:** Version `3.14.0` atau lebih tinggi
- **Android Target SDK:** `34` (Android 14)
- **Android Min SDK:** `21` (Android 5.0 Lollipop)
- **Koneksi Internet Aktif** untuk sinkronisasi data Supabase dan streaming video pembelajaran

---

## Instalasi

1. Klon repositori dari GitHub:
   ```bash
   git clone https://github.com/daudsutanssyah/e-learning-platform.git
   cd e-learning-platform
   ```
2. Unduh seluruh dependensi proyek:
   ```bash
   flutter pub get
   ```

---

## Konfigurasi

**Aplikasi ini bersifat Plug-and-Play (Zero Setup):**
Kredensial publik Supabase telah dikonfigurasi secara default pada konstanta aman [lib/core/constants/supabase_config.dart](lib/core/constants/supabase_config.dart). Anda **tidak perlu** membuat berkas `.env` atau menambahkan argumen konfigurasi tambahan saat menjalankan proyek.

*(Opsional) Override Kredensial:* Jika ingin menghubungkan ke instance Supabase PostgreSQL milik Anda sendiri, berikan parameter compile-time `--dart-define`:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

---

## Cara Menjalankan & Pengujian

Gunakan perintah siap salin berikut untuk memverifikasi kualitas kode dan menjalankan aplikasi:

### 1. Analisis Statis Kode (Linter)
Memastikan kode bebas dari *error*, *warning*, dan mematuhi aturan linting Flutter:
```bash
flutter analyze
```
*Hasil yang diharapkan: `No issues found!`*

### 2. Pengujian Otomatis (Automated Tests)
Menjalankan seluruh 16 unit test dan widget test (use cases, skeleton shimmer, dan widget rendering):
```bash
flutter test
```
*Hasil yang diharapkan: `All tests passed!` (16 unit & widget tests passed).*

### 3. Menjalankan Aplikasi di Emulator / Perangkat Fisik
```bash
flutter run
```

### 4. Membangun Berkas Rilis APK (Production Build)
```bash
flutter build apk --release
```
*Berkas APK rilis yang dihasilkan siap diuji pada: `build/app/outputs/flutter-apk/app-release.apk`.*

---

## Akun Demo & Catatan Pengujian untuk Reviewer

### Tidak Memerlukan Akun Demo atau Login
Aplikasi ini berfokus murni pada pengalaman belajar siswa (*student-first consumption flow*). Seluruh katalog kursus dan silabus materi diakses secara publik (*read-only*) langsung dari Supabase PostgreSQL API, sedangkan riwayat progres pembelajaran dan status penyelesaian materi disimpan secara lokal di perangkat via `shared_preferences`. Reviewer dapat langsung menjelajahi seluruh fitur tanpa harus mendaftar atau masuk ke akun demo.

### 3 Catatan Cepat untuk Pengujian Reviewer:

1. ⚡ **Uji Auto-Complete & Auto-Advance Cepat:**
   Buka kursus apa saja lalu putar materi berdurasi singkat: **`lesson-007`** (durasi ~32 detik) atau **`lesson-010`** (durasi ~30 detik). Biarkan video berputar hingga selesai untuk memverifikasi fitur penandaan otomatis tuntas (*auto-complete*) dan perpindahan otomatis ke materi berikutnya (*auto-advance*) tanpa perlu menunggu video yang panjang.
2. 🛡️ **Uji Penanganan Kasus Tepi & Error State (404 / Broken URL):**
   Buka materi **`lesson-011`** yang sengaja disimulasikan menggunakan tautan video rusak/404. Perhatikan pemutar menampilkan `AppErrorView` informatif lengkap dengan tombol **"Coba Lagi"**, membuktikan ketahanan penanganan kasus batas tanpa menyebabkan aplikasi *crash*.
3. 🔄 **Uji Persistensi Kartu Kelas Aktif:**
   Setelah menandai selesai atau memutar salah satu materi, ketuk tombol kembali ke beranda katalog. Perhatikan kartu ringkasan di bagian atas yang otomatis bertransformasi dari **Cold Start** menjadi **Kelas Aktif** (menampilkan persentase kemajuan riil dan tombol pintasan **"Lanjutkan Belajar"** yang langsung membuka materi berikutnya yang belum selesai).
