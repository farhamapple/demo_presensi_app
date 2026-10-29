import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';

class HistoryController extends GetxController {
  final ScrollController scrollController = ScrollController();

  final RxList<AttendanceRecord> historyList = <AttendanceRecord>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 1.obs;
  final int perPage = 15;

  final Rxn<DateTime> selectedStartDate = Rxn<DateTime>();
  final Rxn<DateTime> selectedEndDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoading.value &&
          !isLoadingMore.value &&
          hasMore.value) {
        loadMore();
      }
    });
  }

  Future<void> fetchHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final startDateStr = selectedStartDate.value != null
        ? DateFormat('yyyy-MM-dd').format(selectedStartDate.value!)
        : null;
    final endDateStr = selectedEndDate.value != null
        ? DateFormat('yyyy-MM-dd').format(selectedEndDate.value!)
        : null;

    final response = await ApiService.getAttendanceHistory(
      page: currentPage.value,
      perPage: perPage,
      startDate: startDateStr,
      endDate: endDateStr,
    );

    isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      final records = response.data!.data;
      final meta = response.data!.meta;

      if (currentPage.value == 1) {
        historyList.assignAll(records);
      } else {
        historyList.addAll(records);
      }

      if (meta != null) {
        hasMore.value = meta.currentPage < meta.lastPage;
      } else {
        hasMore.value = records.length >= perPage;
      }
    } else {
      errorMessage.value =
          response.message ?? 'Gagal memuat riwayat presensi.';
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    final startDateStr = selectedStartDate.value != null
        ? DateFormat('yyyy-MM-dd').format(selectedStartDate.value!)
        : null;
    final endDateStr = selectedEndDate.value != null
        ? DateFormat('yyyy-MM-dd').format(selectedEndDate.value!)
        : null;

    final response = await ApiService.getAttendanceHistory(
      page: currentPage.value,
      perPage: perPage,
      startDate: startDateStr,
      endDate: endDateStr,
    );

    isLoadingMore.value = false;

    if (response.isSuccess && response.data != null) {
      final records = response.data!.data;
      final meta = response.data!.meta;

      historyList.addAll(records);

      if (meta != null) {
        hasMore.value = meta.currentPage < meta.lastPage;
      } else {
        hasMore.value = records.length >= perPage;
      }
    } else {
      // Revert page increment on failure
      currentPage.value--;
    }
  }

  void setDateFilter(DateTime? start, DateTime? end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    fetchHistory(isRefresh: true);
  }

  void clearFilter() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    fetchHistory(isRefresh: true);
  }

  // Format Helper: Tanggal Indonesia
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
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
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  // Format Helper: Jam (HH:mm WIB)
  String formatTime(String? isoStr) {
    if (isoStr == null || isoStr.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m WIB';
    } catch (_) {
      return isoStr;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

