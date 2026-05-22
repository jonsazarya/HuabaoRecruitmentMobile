![Banner](https://raw.githubusercontent.com/jonsazarya/HuabaoRecruitmentMobile/main/assets/images/banner1.png)

# 🏢 Huabao Recruitment Mobile

Aplikasi mobile rekrutmen milik **Huabao** yang dibangun menggunakan **Flutter**, mendukung platform Android, iOS, Web, Linux, macOS, dan Windows.

---

## 📱 Tentang Aplikasi

**Huabao Recruitment Mobile** adalah aplikasi rekrutmen yang memudahkan proses pencarian dan pendaftaran lowongan kerja. Aplikasi ini dilengkapi dengan fitur autentikasi via Google, tampilan lowongan yang interaktif, serta dukungan dokumen PDF untuk detail informasi rekrutmen.

---

## 🚀 Fitur Utama

- **Autentikasi** — Login menggunakan akun Google via Firebase Authentication
- **Tampilan Lowongan** — Carousel slider untuk menampilkan lowongan secara menarik
- **Navigasi Intuitif** — Curved bottom navigation bar untuk pengalaman pengguna yang nyaman
- **Dokumen PDF** — Tampilan dokumen PDF langsung di dalam aplikasi
- **Animasi** — Animasi UI yang halus menggunakan `flutter_animate`
- **Deep Linking** — Dukungan App Links untuk navigasi via URL eksternal
- **Penyimpanan Lokal** — Menyimpan preferensi pengguna dengan `shared_preferences`
- **Google Fonts** — Tipografi premium menggunakan Google Fonts

---

## 🛠️ Teknologi yang Digunakan

| Kategori | Package | Versi |
|---|---|---|
| HTTP Client | `http` | ^1.2.0 |
| Local Storage | `shared_preferences` | ^2.2.2 |
| Fonts | `google_fonts` | ^6.1.0 |
| Navigasi | `curved_navigation_bar` | ^1.0.1 |
| Slider | `carousel_slider` | ^5.0.0 |
| Backend | `firebase_core` | ^3.1.0 |
| Auth | `firebase_auth` | ^5.1.0 |
| Login Google | `google_sign_in` | ^6.2.1 |
| Animasi | `flutter_animate` | ^4.5.0 |
| Deep Link | `app_links` | ^6.0.0 |
| PDF Viewer | `flutter_pdfview` | ^1.3.2 |
| Path | `path_provider` | ^2.1.2 |

---

## ⚙️ Persyaratan Sistem

- **Flutter SDK**: `^3.11.5`
- **Dart SDK**: `^3.11.5`
- **Android**: minimum SDK `21` (Android 5.0 Lollipop)
- **iOS**: versi yang didukung Flutter terbaru

---

## 📦 Instalasi & Menjalankan Proyek

### 1. Clone Repository

```bash
git clone https://github.com/jonsazarya/HuabaoRecruitmentMobile.git
cd HuabaoRecruitmentMobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Firebase

- Buat project baru di [Firebase Console](https://console.firebase.google.com/)
- Download file `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
- Letakkan file tersebut di direktori yang sesuai:
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`

### 4. Jalankan Aplikasi

```bash
# Android / iOS
flutter run

# Web
flutter run -d chrome

# Specific device
flutter run -d <device_id>
```

---

## 🏗️ Struktur Proyek

```
HuabaoRecruitmentMobile/
├── android/          # Konfigurasi platform Android
├── ios/              # Konfigurasi platform iOS
├── web/              # Konfigurasi platform Web
├── linux/            # Konfigurasi platform Linux
├── macos/            # Konfigurasi platform macOS
├── windows/          # Konfigurasi platform Windows
├── lib/              # Source code utama Dart/Flutter
│   └── main.dart     # Entry point aplikasi
├── assets/
│   ├── images/       # Gambar & logo aplikasi
│   └── pdf/          # File PDF
├── test/             # Unit & widget tests
├── pubspec.yaml      # Konfigurasi project & dependencies
└── firebase.json     # Konfigurasi Firebase
```

---

## 🎨 Ikon Aplikasi

Ikon aplikasi dikonfigurasi menggunakan `flutter_launcher_icons`:

- **Image**: `assets/images/logo_huabao_recruitment.png`
- **Adaptive Icon Background**: `#1D5D9B` (Biru Huabao)
- **Platform**: Android & iOS

Untuk generate ulang ikon:

```bash
flutter pub run flutter_launcher_icons
```

---

## 🔥 Konfigurasi Firebase

Aplikasi ini menggunakan layanan Firebase berikut:

- **Firebase Core** — Inisialisasi Firebase
- **Firebase Authentication** — Autentikasi pengguna
- **Google Sign-In** — Login dengan akun Google

---

## 🧪 Menjalankan Tests

```bash
flutter test
```

---

## 📋 Build untuk Produksi

### Android (APK)

```bash
flutter build apk --release
```

### Android (App Bundle)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

---

## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b feature/nama-fitur`)
3. Commit perubahan (`git commit -m 'feat: tambah fitur baru'`)
4. Push ke branch (`git push origin feature/nama-fitur`)
5. Buat Pull Request

---

## 📞 Kontak

Untuk informasi lebih lanjut, silakan hubungi tim pengembang melalui repository ini.
