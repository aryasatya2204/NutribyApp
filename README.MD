# NutriBy: Solusi Cerdas Pencegahan Stunting 👶

NutriBy adalah aplikasi mobile komprehensif yang dirancang untuk membantu orang tua di Indonesia dalam mencegah stunting pada anak usia 6-24 bulan. Aplikasi ini menyediakan rekomendasi MPASI (Makanan Pendamping ASI) yang dipersonalisasi, informasi gizi, dan perencanaan makan mingguan yang cerdas, dengan mempertimbangkan status gizi anak dan kondisi ekonomi keluarga.

---

## 👥 Anggota Kelompok

| No | Nama | NIM | Peran |
|----|------|-----|-------|
| 1 | Muhammad Aryasatya | 231401094 | Project Manager / Backend |
| 2 | Muhammad Alif Akbar Harahap | 231401127 | UIUX / Database |
| 3 | Yazid Ilmi Ihsan | 231401037 | Frontend / System Analys |

# ✨ Fitur Utama

### 🔐 Autentikasi & Pengguna

* **Login & Register:** Autentikasi aman menggunakan Email & Password via Firebase Auth
* **Google Sign-In:** Login cepat satu ketukan menggunakan akun Google
* **Manajemen Profil:** Pengguna dapat mengatur data diri (berat/tinggi badan), target kalori, dan logout dengan aman

### 🍎 Pelacakan Nutrisi & Makanan

* **Database Makanan:** Pencarian database makanan lengkap (Kalori, Protein, Karbo, Lemak)
* **Pencarian Pintar:** Cari makanan atau minuman dengan fitur *debounce* untuk efisiensi API
* **Barcode Scanner:** Pindai *barcode* kemasan makanan untuk mendapatkan informasi nilai gizi secara instan
* **Daily Log:** Mencatat asupan sarapan, makan siang, makan malam, dan camilan harian

### 📊 Analisis Kesehatan (Cloud Sync)

* **Kalkulator BMI:** Menghitung Indeks Massa Tubuh secara otomatis berdasarkan profil pengguna
* **Grafik Progress:** Visualisasi data asupan kalori mingguan untuk memantau target diet
* **Sinkronisasi Real-time:** Riwayat makan disimpan di **Cloud Firestore**, sehingga data tetap aman meski berganti perangkat

### 🎨 UI/UX Modern

* **Responsive Design:** Tampilan antarmuka yang menyesuaikan ukuran layar (ponsel & tablet)
* **Clean Dashboard:** Ringkasan nutrisi harian ditampilkan dengan visual yang mudah dipahami
* **Optimasi Performa:** Menggunakan *lazy loading* pada daftar makanan untuk mempercepat navigasi
---

## 🛠️ Teknologi yang Digunakan (Tech Stack)

| Kategori               | Teknologi / Library    | Deskripsi                                                                         |
| ---------------------- | ---------------------- | --------------------------------------------------------------------------------- |
| **Backend Framework**  | Laravel 12 (PHP)       | Framework utama untuk membangun RESTful API yang scalable dan terstruktur         |
| **Frontend Framework** | Flutter 3 (Dart)       | Framework cross-platform untuk membangun aplikasi mobile Android dan iOS          |
| **State Management**   | Provider               | Mengelola state aplikasi Flutter secara efisien dan reaktif                       |
| **API Architecture**   | REST API               | Arsitektur komunikasi antara frontend dan backend berbasis HTTP                   |
| **Authentication**     | Laravel Sanctum        | Menyediakan autentikasi API berbasis token yang aman                              |
| **Database**           | MySQL                  | Sistem manajemen basis data relasional untuk menyimpan data pengguna dan aplikasi |
| **ORM**                | Eloquent ORM           | Mempermudah interaksi database dengan pendekatan object-relational mapping        |
| **Network Client**     | HTTP Package (Flutter) | Melakukan request API (GET, POST, PUT, DELETE) dari aplikasi mobile               |
| **API Testing**        | Postman                | Pengujian endpoint API untuk memastikan fungsionalitas dan validasi data          |
| **Data Format**        | JSON                   | Format pertukaran data antara backend Laravel dan frontend Flutter                |
| **Version Control**    | Git & GitHub           | Mengelola versi kode sumber dan kolaborasi pengembangan                           |
| **Security**           | CSRF & Middleware      | Perlindungan endpoint API dan validasi request                                    |
| **UI Components**      | Material UI (Flutter)  | Komponen antarmuka berbasis Material Design                                       |
| **Development Tools**  | VS Code                | Code editor utama untuk pengembangan backend dan frontend                         |

## 📁 Struktur Project

```bash
lib/
├── config/
│   └── routes.dart
│
├── models/
│   ├── food.dart
│   ├── nutrition.dart
│   └── user_profile.dart
│
├── providers/
│   ├── app_state_provider.dart
│   ├── auth_provider.dart
│   └── nutrition_provider.dart
│
├── repositories/
│   ├── food_repository.dart
│   └── user_repository.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── food_detail_screen.dart
│   ├── tracker_screen.dart
│   ├── favorite_screen.dart
│   ├── profile_screen.dart
│   ├── signin_screen.dart
│   └── signup_screen.dart
│
├── services/
│   ├── auth/
│   │   └── firebase_auth_service.dart
│   ├── firestore_service.dart
│   └── nutrition_api_service.dart
│
├── utils/
│   ├── snackbar_helper.dart
│   ├── validators.dart
│   └── constants.dart
│
├── widgets/
│   ├── food_card.dart
│   ├── nutrition_info.dart
│   ├── app_scaffold.dart
│   ├── bottom_navigation_shell.dart
│   └── favorite_food_card.dart
│
└── main.dart
```
---

## 🚀 Panduan Instalasi & Setup

Proyek ini terdiri dari dua bagian utama: **Backend (nutriby_api)** dan **Frontend (nutriby_app)**.

### 1. Backend Setup (nutriby_api)

Pastikan Anda memiliki PHP, Composer, dan MySQL terinstal.

1.  **Pindah ke direktori backend:**
    ```bash
    cd nutriby_api
    ```
2.  **Salin file environment:**
    ```bash
    cp .env.example .env
    ```
3.  **Instal dependensi Composer:**
    ```bash
    composer install
    ```
4.  **Buat kunci aplikasi:**
    ```bash
    php artisan key:generate
    ```
5.  **Konfigurasi Database:** Buka file `.env` dan sesuaikan pengaturan `DB_*` dengan konfigurasi MySQL Anda. Pastikan Anda sudah membuat database kosong untuk proyek ini.
6.  **Jalankan migrasi dan seeder:** Perintah ini akan membuat semua tabel dan mengisinya dengan data awal (standar WHO & resep).
    ```bash
    php artisan migrate:fresh --seed
    ```
7.  **Jalankan server pengembangan:**
    ```bash
    php artisan serve
    ```
    Backend sekarang berjalan di `http://127.0.0.1:8000`.

### 2. Frontend Setup (nutriby_app)

Pastikan Anda memiliki Flutter SDK terinstal.

1.  **Pindah ke direktori frontend:**
    ```bash
    cd nutriby_app
    ```
2.  **Instal dependensi Flutter:**
    ```bash
    flutter pub get
    ```
3.  **Konfigurasi Alamat API:** Buka file konfigurasi (misalnya `lib/utils/constants.dart`) dan pastikan base URL API mengarah ke server backend Anda (`http://127.0.0.1:8000/api`).
4.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

## 🐛 Troubleshooting

### ❌ Google Sign-In Error (Code 10 / DEVELOPER_ERROR)

**Solusi:**

* Pastikan SHA-1 sudah terdaftar di Firebase
* Download ulang `google-services.json` dan timpa yang lama
* Rebuild aplikasi: `flutter clean && flutter build apk --release`

### ❌ Firebase Connection Failed

**Solusi:**

* Cek apakah `google-services.json` ada di `android/app/`
* Pastikan package name di Firebase sama dengan di `build.gradle.kts`
* Sinkronkan gradle: `cd android && ./gradlew --refresh-dependencies`

### ❌ Keystore Error saat Build

**Solusi:**

* Periksa password di `key.properties` sudah benar
* Pastikan path `storeFile` mengarah ke file `.jks` yang valid

## 📚 Dokumentasi API

Dokumentasi API lengkap, termasuk contoh request dan response untuk setiap endpoint, tersedia melalui Postman. Silakan impor koleksi Postman yang tersedia atau kunjungi link publikasi berikut:

**[Link ke Dokumantasi API akan di letak disini (soon)]**

---

Dikembangkan dengan ❤️ untuk masa depan anak Indonesia yang lebih sehat.
