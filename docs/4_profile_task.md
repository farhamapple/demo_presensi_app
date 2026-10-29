# Task 4: Implementasi Halaman Profil Pegawai & Pengaturan

Dokumentasi ini menjelaskan implementasi halaman **Profil Pegawai** pada aplikasi **Si Presensi** menggunakan **GetX**, integrasi endpoint `GET /auth/me` dan `POST /auth/logout`, serta visualisasi konfigurasi `.env`.

---

## 📌 1. Checklist Implementasi

- [x] **Integrasi Data Profil Pegawai (`GET /auth/me`)**:
  - Mengambil data profil lengkap dari server (Nama, NIP, Email, Unit Kerja, Jabatan, No. Telepon, Role, Status Akun, dan Avatar URL).
  - Mekanisme *caching*: Memuat data dari local storage terlebih dahulu agar UI instan, lalu memperbarui data secara asynchronous dari API dan menyimpannya kembali ke SharedPreferences.
  - Pull-to-refresh untuk menyegarkan data profil kapan saja.
- [x] **Visualisasi Konfigurasi Environment (`.env`)**:
  - Menampilkan Base API URL (`https://demo-presensi.farham.my.id/api/v1`) dan Base Host (`https://demo-presensi.farham.my.id`) secara rapi dan dapat disalin (*SelectableText*).
- [x] **Fitur Logout (`POST /auth/logout`)**:
  - Memanggil endpoint pencabutan token sesi Sanctum di backend.
  - Menghapus token dan data user dari local storage via `StorageService.clearAll()`.
  - Dialog konfirmasi sebelum keluar.
  - Navigasi kembali ke `LoginPage` menggunakan `Get.offAll(() => const LoginPage())`.

---

## 📂 2. Struktur Berkas yang Terlibat

```text
lib/
├── services/
│   └── api_service.dart             # Penambahan method getMe() & logout()
├── controllers/
│   └── profile_controller.dart      # Pengendali GetX untuk memuat profil, baca .env, & proses logout
└── pages/
    └── profile_page.dart            # Tampilan kartu profil, informasi server .env, & tombol logout
```

---

## 🔌 3. Endpoint API yang Digunakan

### 1. Get Profil Pegawai
- **URL**: `GET /api/v1/auth/me`
- **Headers**:
  ```http
  Authorization: Bearer <token_sanctum>
  Accept: application/json
  ```
- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "data": {
      "id": 2,
      "name": "Budi Pratama",
      "email": "budi@kantor.com",
      "nip": "199205122018021002",
      "unit_kerja": "Direktorat Aparatur Negara",
      "jabatan": "Pranata Komputer Ahli Muda",
      "phone": "081298765432",
      "avatar_url": null,
      "role": "pegawai",
      "is_active": true
    }
  }
  ```

### 2. Logout Pegawai
- **URL**: `POST /api/v1/auth/logout`
- **Headers**:
  ```http
  Authorization: Bearer <token_sanctum>
  Accept: application/json
  ```
- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "message": "Logout berhasil. Sesi token telah dicabut."
  }
  ```
