import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/main_navigation_page.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    final response = await ApiService.login(
      identifier: identifierController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      final token = response.data!.token;
      final user = response.data!.user;

      if (token != null) {
        await StorageService.saveToken(token);
      }
      if (user != null) {
        await StorageService.saveUser(user);
      }

      Get.snackbar(
        'Berhasil',
        response.message ?? 'Login berhasil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );

      Get.offAll(() => const MainNavigationPage());
    } else {
      Get.snackbar(
        'Login Gagal',
        response.message ?? 'Terjadi kesalahan saat login',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

