# Spesifikasi API Mobile: SiAbsen

Dokumentasi ini ditujukan bagi pengembang aplikasi mobile (*Flutter / React Native / Android Kotlin / iOS Swift*) untuk mengintegrasikan fitur presensi mobile dengan backend **SiAbsen**.

---

## 🌐 1. Informasi Dasar

- **Base URL**: `http://localhost:8000/api/v1` (atau domain server produksi)
- **Format Pertukaran Data**: `application/json`
- **Header Wajib**:
  ```http
  Accept: application/json
  Content-Type: application/json
  ```
- **Header Autentikasi** (untuk endpoint terproteksi):
  ```http
  Authorization: Bearer <token_sanctum>
  ```
- **Zona Waktu**: Seluruh nilai waktu menggunakan zona waktu lokal **WIB (`Asia/Jakarta`)** dan berformat ISO 8601 (`YYYY-MM-DDTHH:mm:ssZ`).

---

## 🛡️ 2. Kode Status HTTP & Format Respons

| Kode HTTP | Keterangan |
|---|---|
| `200 OK` | Permintaan berhasil diproses. |
| `201 Created` | Data presensi baru berhasil dicatat. |
| `401 Unauthorized` | Token tidak disertakan, tidak valid, atau telah kadaluarsa. |
| `422 Unprocessable Entity` | Validasi input gagal (misal: kredensial salah, di luar radius, double check-in). |
| `500 Internal Server Error` | Terjadi kesalahan pada server backend. |

### Format Standar Respons Sukses
```json
{
  "message": "Pesan deskripsi keberhasilan",
  "data": { ... }
}
```

### Format Standar Respons Error Validasi (`422`)
```json
{
  "message": "Pesan umum kesalahan validasi.",
  "errors": {
    "field_name": [
      "Pesan detail kegagalan validasi."
    ]
  }
}
```

---

## 🔑 3. Endpoint Autentikasi

### 3.1. Login Pegawai
Digunakan oleh pegawai untuk masuk ke aplikasi mobile menggunakan Email atau NIP serta kata sandi.

- **URL**: `/api/v1/auth/login`
- **Metode**: `POST`
- **Autentikasi**: Tidak perlu (Public)
- **Request Body**:
  ```json
  {
    "identifier": "budi@kantor.com",
    "password": "password123",
    "device_name": "Samsung Galaxy S23 (SM-S911B)"
  }
  ```
  *(Catatan: `identifier` dapat berupa Email ataupun NIP pegawai)*

- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "message": "Login berhasil.",
    "data": {
      "user": {
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
      },
      "token": "1|AbCdEf1234567890...",
      "token_type": "Bearer"
    }
  }
  ```

---

### 3.2. Get Profil Pegawai (`/me`)
Mengambil data profil lengkap pegawai yang sedang login.

- **URL**: `/api/v1/auth/me`
- **Metode**: `GET`
- **Autentikasi**: `Bearer Token`
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

---

### 3.3. Logout
Mencabut dan menghapus sesi token yang sedang aktif pada perangkat.

- **URL**: `/api/v1/auth/logout`
- **Metode**: `POST`
- **Autentikasi**: `Bearer Token`
- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "message": "Logout berhasil. Sesi token telah dicabut."
  }
  ```

---

## 📍 4. Endpoint Lokasi Kantor & Geofence

### 4.1. Daftar Lokasi Kantor Aktif
Mengambil seluruh titik lokasi kantor yang aktif untuk digambar pada komponen peta aplikasi mobile smartphone.

- **URL**: `/api/v1/office-locations`
- **Metode**: `GET`
- **Autentikasi**: `Bearer Token`
- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "message": "Daftar lokasi kantor aktif berhasil dimuat.",
    "data": [
      {
        "id": 1,
        "name": "Kantor Pusat Jakarta",
        "address": "Jl. Taman Suropati No. 2, Menteng, Jakarta Pusat",
        "latitude": -6.17565,
        "longitude": 106.82725,
        "radius_meters": 150,
        "polygon_coordinates": [
          {"lat": -6.1748, "lng": 106.826},
          {"lat": -6.1748, "lng": 106.8285},
          {"lat": -6.1765, "lng": 106.8285},
          {"lat": -6.1765, "lng": 106.826}
        ],
        "is_active": true
      }
    ]
  }
  ```

---

## ⏱️ 5. Endpoint Presensi Pegawai

### 5.1. Check-In (Absen Masuk)
Mengirimkan koordinat GPS pegawai saat melakukan presensi masuk kerja. Backend otomatis memvalidasi apakah koordinat berada di dalam area polygon / radius kantor yang dipilih.

- **URL**: `/api/v1/attendance/check-in`
- **Metode**: `POST`
- **Autentikasi**: `Bearer Token`
- **Request Body**:
  ```json
  {
    "office_location_id": 1,
    "latitude": -6.175500,
    "longitude": 106.827000,
    "device_name": "Samsung Galaxy S23 (Android 14)",
    "device_id": "sec-uuid-987162aa-34bc",
    "notes": "Hadir tepat waktu"
  }
  ```

- **Respons Sukses (`201 Created`)**:
  ```json
  {
    "message": "Presensi masuk berhasil dicatat.",
    "data": {
      "id": 10,
      "user_id": 2,
      "office_location_id": 1,
      "office_location": {
        "id": 1,
        "name": "Kantor Pusat Jakarta",
        "address": "Jl. Taman Suropati No. 2, Menteng, Jakarta Pusat",
        "latitude": -6.17565,
        "longitude": 106.82725,
        "radius_meters": 150
      },
      "date": "2026-10-26",
      "check_in_at": "2026-10-26T07:45:00+07:00",
      "check_out_at": null,
      "check_in_latitude": -6.1755,
      "check_in_longitude": 106.827,
      "check_out_latitude": null,
      "check_out_longitude": null,
      "distance_meters": 24.5,
      "status": {
        "value": "present",
        "label": "Hadir",
        "color": "success"
      },
      "notes": "Hadir tepat waktu",
      "device_name": "Samsung Galaxy S23 (Android 14)",
      "device_id": "sec-uuid-987162aa-34bc",
      "ip_address": "192.168.1.50",
      "check_out_device_name": null
    }
  }
  ```

- **Respons Gagal Double Check-In (`422 Unprocessable Entity`)**:
  ```json
  {
    "message": "Anda sudah melakukan absen masuk untuk hari ini.",
    "errors": {
      "attendance": [
        "Anda sudah melakukan absen masuk untuk hari ini."
      ]
    }
  }
  ```

---

### 5.2. Check-Out (Absen Pulang)
Mengirimkan koordinat GPS pegawai saat melakukan presensi kepulangan kerja.

- **URL**: `/api/v1/attendance/check-out`
- **Metode**: `POST`
- **Autentikasi**: `Bearer Token`
- **Request Body**:
  ```json
  {
    "latitude": -6.175520,
    "longitude": 106.827050,
    "device_name": "Samsung Galaxy S23 (Android 14)",
    "notes": "Selesai jam kerja harian"
  }
  ```

- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "message": "Presensi pulang berhasil dicatat.",
    "data": {
      "id": 10,
      "user_id": 2,
      "date": "2026-10-26",
      "check_in_at": "2026-10-26T07:45:00+07:00",
      "check_out_at": "2026-10-26T17:05:00+07:00",
      "check_out_latitude": -6.17552,
      "check_out_longitude": 106.82705,
      "check_out_device_name": "Samsung Galaxy S23 (Android 14)",
      "status": {
        "value": "present",
        "label": "Hadir",
        "color": "success"
      }
    }
  }
  ```

---

### 5.3. Status Presensi Hari Ini
Mengecek status apakah pegawai telah melakukan presensi masuk dan/atau pulang pada hari ini.

- **URL**: `/api/v1/attendance/today`
- **Metode**: `GET`
- **Autentikasi**: `Bearer Token`
- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "has_checked_in": true,
    "has_checked_out": false,
    "data": {
      "id": 10,
      "date": "2026-10-26",
      "check_in_at": "2026-10-26T07:45:00+07:00",
      "check_out_at": null,
      "status": {
        "value": "present",
        "label": "Hadir",
        "color": "success"
      }
    }
  }
  ```

---

### 5.4. Riwayat Presensi Pegawai
Mengambil daftar riwayat presensi pegawai dengan dukungan pagination dan filter rentang tanggal.

- **URL**: `/api/v1/attendance/history?per_page=15&start_date=2026-10-01&end_date=2026-10-31`
- **Metode**: `GET`
- **Autentikasi**: `Bearer Token`
- **Parameter Query (Opsional)**:
  - `start_date`: Tanggal awal (format `YYYY-MM-DD`)
  - `end_date`: Tanggal akhir (format `YYYY-MM-DD`)
  - `per_page`: Jumlah data per halaman (default `15`, maks `100`)
  - `page`: Nomor halaman aktif (default `1`)

- **Respons Sukses (`200 OK`)**:
  ```json
  {
    "data": [
      {
        "id": 10,
        "date": "2026-10-26",
        "check_in_at": "2026-10-26T07:45:00+07:00",
        "check_out_at": "2026-10-26T17:05:00+07:00",
        "status": {
          "value": "present",
          "label": "Hadir",
          "color": "success"
        },
        "distance_meters": 24.5,
        "device_name": "Samsung Galaxy S23 (Android 14)"
      }
    ],
    "links": {
      "first": "http://localhost:8000/api/v1/attendance/history?page=1",
      "last": "http://localhost:8000/api/v1/attendance/history?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "per_page": 15,
      "to": 1,
      "total": 1
    }
  }
  ```

---

## 📱 6. Nilai Status Kehadiran (`AttendanceStatus`)

| Value | Label | Deskripsi |
|---|---|---|
| `present` | Hadir | Presensi di dalam area kantor dan sebelum/pada jam 08:00 WIB. |
| `late` | Terlambat | Presensi di dalam area kantor tetapi melewati jam 08:00 WIB. |
| `outside_area` | Di Luar Area | Presensi dilakukan di luar area polygon / radius kantor yang diperbolehkan. |

