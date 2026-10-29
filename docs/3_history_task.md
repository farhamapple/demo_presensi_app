# Task 3: Implementasi Halaman Riwayat Presensi

Dokumentasi ini menjelaskan implementasi halaman **Riwayat Presensi** pegawai pada aplikasi **Si Presensi** menggunakan **GetX**, integrasi endpoint `GET /attendance/history`, paginasi, filter rentang tanggal, dan tampilan Card/List.

---

## 📌 1. Checklist Implementasi

- [x] **Model Riwayat Presensi & Paginasi**:
  - [`history_response_model.dart`](../lib/models/history_response_model.dart): Serialisasi data riwayat dan metadata paginasi (`current_page`, `last_page`, `per_page`, `total`).
- [x] **Integrasi Endpoint API**:
  - `GET /api/v1/attendance/history`: Mendukung parameter `page`, `per_page`, `start_date`, dan `end_date` dengan autentikasi Bearer token.
- [x] **Controller Riwayat (`HistoryController`)**:
  - Mengelola pemuatan data awal, *infinite scrolling* (load more saat mencapai akhir scroll), *pull-to-refresh*, dan penanganan filter tanggal.
- [x] **Tampilan Antarmuka (`HistoryPage`)**:
  - **Daftar Kartu Presensi**: Tanggal format Bahasa Indonesia, badge status berwarna (`Hadir`, `Terlambat`, `Di Luar Area`).
  - **Waktu Presensi**: Jam masuk dan jam pulang dengan ikon arah panah yang jelas.
  - **Filter Tanggal**: Dialog pemilih rentang tanggal (*Date Range Picker*) dengan banner chip aktif yang dapat dibatalkan sewaktu-waktu.
  - **Kondisi State UX**: Indikator loading, empty state (bila belum ada data riwayat), dan error state lengkap dengan tombol "Coba Lagi".

---

## 📂 2. Struktur Berkas yang Terlibat

```text
lib/
├── models/
│   ├── attendance_model.dart        # Penambahan field deviceName pada AttendanceRecord
│   └── history_response_model.dart  # Model data list riwayat dan PaginationMeta
├── services/
│   └── api_service.dart             # Penambahan method getAttendanceHistory(...)
├── controllers/
│   └── history_controller.dart      # Pengendali GetX untuk fetch data, paginasi, & filter
└── pages/
    └── history_page.dart            # Tampilan kartu riwayat presensi, filter dialog, & refresh
```

---

## 🔌 3. Endpoint API yang Digunakan

- **URL**: `GET /api/v1/attendance/history`
- **Headers**:
  ```http
  Authorization: Bearer <token_sanctum>
  Accept: application/json
  ```
- **Query Parameter**:
  - `page`: Nomor halaman (contoh: `1`)
  - `per_page`: Jumlah data per halaman (contoh: `15`)
  - `start_date`: Tanggal awal format `YYYY-MM-DD` (opsional)
  - `end_date`: Tanggal akhir format `YYYY-MM-DD` (opsional)

### Format Respons Sukses (`200 OK`)
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
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 1
  }
}
```
