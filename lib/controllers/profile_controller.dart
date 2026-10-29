import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../pages/login_page.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProfileController extends GetxController {
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = true.obs;
  final RxBool isLoggingOut = false.obs;

  String get serverUrl =>
      dotenv.env['BASE_URL'] ?? 'https://demo-presensi.farham.my.id/api/v1';

  String get serverHost =>
      dotenv.env['BASE_HOST'] ?? 'https://demo-presensi.farham.my.id';

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    // 1. Ambil dari local storage terlebih dahulu agar UI cepat tampil
    final cached = await StorageService.getUser();
    if (cached != null) {
      user.value = cached;
      isLoading.value = false;
    }

    // 2. Ambil data terbaru dari endpoint GET /auth/me
    final response = await ApiService.getMe();
    isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      user.value = response.data;
      await StorageService.saveUser(response.data!);
    }
  }

  Future<void> logout() async {
    isLoggingOut.value = true;

    // Panggil API logout backend
    await ApiService.logout();

    // Hapus sesi lokal di shared preferences
    await StorageService.clearAll();

    isLoggingOut.value = false;

    Get.snackbar(
      'Logout',
      'Anda telah berhasil keluar dari akun.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );

    Get.offAll(() => const LoginPage());
  }
}

