# NutriBy: Solusi Cerdas Pencegahan Stunting 👶

NutriBy adalah aplikasi mobile komprehensif yang dirancang untuk membantu orang tua di Indonesia dalam mencegah stunting pada anak usia 6-24 bulan. Aplikasi ini menyediakan rekomendasi MPASI (Makanan Pendamping ASI) yang dipersonalisasi, informasi gizi, dan perencanaan makan mingguan yang cerdas, dengan mempertimbangkan status gizi anak dan kondisi ekonomi keluarga.

---

## ✨ Fitur Utama

- **👤 Profil Anak Personal:** Mencatat data antropometri anak (berat, tinggi, usia) dan kondisi orang tua (pendapatan) untuk memberikan rekomendasi yang terpersonalisasi.
- **🧠 Engine Status Gizi Cerdas:** Secara otomatis menghitung status gizi anak (HFA, WFA, WFH) berdasarkan standar WHO untuk mendeteksi risiko stunting, gizi kurang, atau gizi buruk.
- **💰 Rekomendasi Budget Dinamis:** Memberikan rekomendasi rentang budget MPASI bulanan yang realistis, dihitung berdasarkan kebutuhan gizi anak dan kemampuan finansial keluarga.
- **🍲 Generate MPASI Mingguan:** Fitur inti yang secara otomatis membuat rencana makan 21 menu untuk satu minggu penuh, disesuaikan dengan budget, usia, status gizi, alergi, dan makanan kesukaan anak.
- **🔍 Pencarian Resep Fleksibel:** Memungkinkan pengguna mencari resep berdasarkan nama menu ataupun bahan makanan yang mereka miliki di rumah.
- ** Fakta Alergi:** Menyediakan informasi mengenai alergi makanan, gejala, dan cara penanganannya.

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
│       # Konfigurasi GoRouter & guard navigasi (auth / onboarding)
│
├── models/
│   ├── food.dart
│   │   # Data model makanan (JSON serialization)
│   ├── nutrition.dart
│   │   # Model informasi gizi (kalori, protein, lemak, dll)
│   └── user_profile.dart
│       # Model data profil pengguna
│
├── providers/
│   ├── app_state_provider.dart
│   │   # State utama aplikasi (makanan, kalkulasi gizi, UI state)
│   ├── auth_provider.dart
│   │   # Logic autentikasi user & sinkronisasi UI
│   └── nutrition_provider.dart
│       # Logic perhitungan & manajemen nutrisi
│
├── repositories/
│   ├── food_repository.dart
│   │   # Layer komunikasi ke API / data sumber makanan
│   └── user_repository.dart
│       # Akses data user (Firestore / local storage)
│
├── screens/
│   ├── home_screen.dart
│   │   # Dashboard utama NutribyApp
│   ├── food_detail_screen.dart
│   │   # Detail makanan & nilai gizi
│   ├── tracker_screen.dart
│   │   # Halaman tracking konsumsi harian
│   ├── favorite_screen.dart
│   │   # Daftar makanan favorit
│   ├── profile_screen._

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

## 📚 Dokumentasi API

Dokumentasi API lengkap, termasuk contoh request dan response untuk setiap endpoint, tersedia melalui Postman. Silakan impor koleksi Postman yang tersedia atau kunjungi link publikasi berikut:

**[Link ke Dokumantasi API akan di letak disini (soon)]**

---

Dikembangkan dengan ❤️ untuk masa depan anak Indonesia yang lebih sehat.
