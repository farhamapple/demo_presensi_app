import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../models/attendance_model.dart';
import '../models/office_location_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class HomeController extends GetxController {
  final MapController mapController = MapController();

  // 1. Data User
  final Rxn<UserModel> user = Rxn<UserModel>();

  // 2. Realtime Clock
  final Rx<DateTime> currentTime = DateTime.now().obs;
  Timer? _clockTimer;

  // 3. Lokasi & Peta
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxList<OfficeLocationModel> officeLocations = <OfficeLocationModel>[].obs;
  final Rxn<OfficeLocationModel> selectedOffice = Rxn<OfficeLocationModel>();
  final RxBool isInsideOffice = false.obs;
  final RxDouble distanceToOffice = 0.0.obs;
  final RxBool isLocationLoading = true.obs;

  // 4. Data Presensi Hari Ini
  final Rxn<TodayAttendanceResponse> todayAttendance =
      Rxn<TodayAttendanceResponse>();
  final RxBool isAttendanceLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startClock();
    initData();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentTime.value = DateTime.now();
    });
  }

  Future<void> initData() async {
    await fetchProfile();
    await Future.wait([
      fetchTodayAttendance(),
      fetchOfficeLocations(),
    ]);
    await fetchCurrentLocation();
  }

  Future<void> fetchProfile() async {
    final storedUser = await StorageService.getUser();
    if (storedUser != null) {
      user.value = storedUser;
    }
  }

  Future<void> fetchOfficeLocations() async {
    final response = await ApiService.getOfficeLocations();
    if (response.isSuccess && response.data != null) {
      officeLocations.assignAll(response.data!);
      if (officeLocations.isNotEmpty) {
        selectedOffice.value = officeLocations.first;
      }
    }
    _recalculateGeofence();
  }

  Future<void> fetchCurrentLocation() async {
    isLocationLoading.value = true;
    final pos = await LocationService.getCurrentPosition();
    currentPosition.value = pos;
    isLocationLoading.value = false;

    if (pos != null) {
      _recalculateGeofence();
      try {
        mapController.move(LatLng(pos.latitude, pos.longitude), 16.5);
      } catch (_) {}
    }
  }

  void _recalculateGeofence() {
    final pos = currentPosition.value;
    final office = selectedOffice.value;

    if (pos == null || office == null) {
      isInsideOffice.value = false;
      distanceToOffice.value = 0.0;
      return;
    }

    final distance = LocationService.calculateDistanceMeters(
      startLatitude: pos.latitude,
      startLongitude: pos.longitude,
      endLatitude: office.latitude,
      endLongitude: office.longitude,
    );

    distanceToOffice.value = distance;
    isInsideOffice.value = LocationService.isInsideOfficeArea(
      userLat: pos.latitude,
      userLng: pos.longitude,
      office: office,
    );
  }

  Future<void> fetchTodayAttendance() async {
    isAttendanceLoading.value = true;
    final response = await ApiService.getTodayAttendance();
    isAttendanceLoading.value = false;

    if (response.isSuccess && response.data != null) {
      todayAttendance.value = response.data;
    }
  }

  // Aksi Absen Masuk
  Future<void> checkIn() async {
    final pos = currentPosition.value;
    final office = selectedOffice.value;

    if (pos == null || office == null) {
      Get.snackbar(
        'Lokasi Tidak Ditemukan',
        'Mohon aktifkan GPS perangkat Anda terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    final response = await ApiService.checkIn(
      officeLocationId: office.id,
      latitude: pos.latitude,
      longitude: pos.longitude,
    );

    isSubmitting.value = false;

    if (response.isSuccess) {
      Get.snackbar(
        'Berhasil',
        response.message ?? 'Presensi masuk berhasil dicatat!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await fetchTodayAttendance();
    } else {
      Get.snackbar(
        'Presensi Gagal',
        response.message ?? 'Gagal melakukan presensi masuk.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Aksi Absen Pulang
  Future<void> checkOut() async {
    final pos = currentPosition.value;
    if (pos == null) {
      Get.snackbar(
        'Lokasi Tidak Ditemukan',
        'Mohon aktifkan GPS perangkat Anda terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    final response = await ApiService.checkOut(
      latitude: pos.latitude,
      longitude: pos.longitude,
    );

    isSubmitting.value = false;

    if (response.isSuccess) {
      Get.snackbar(
        'Berhasil',
        response.message ?? 'Presensi pulang berhasil dicatat!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await fetchTodayAttendance();
    } else {
      Get.snackbar(
        'Presensi Gagal',
        response.message ?? 'Gagal melakukan presensi pulang.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Format Helper: Tanggal Bahasa Indonesia
  String get formattedDate {
    final now = currentTime.value;
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  // Format Helper: Jam Digital
  String get formattedTime {
    final now = currentTime.value;
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s WIB';
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }
}

