import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/history_controller.dart';
import '../models/attendance_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Riwayat Presensi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded, color: Color(0xFF64748B)),
            tooltip: 'Filter Tanggal',
            onPressed: () => _pickDateRange(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            tooltip: 'Segarkan',
            onPressed: () => controller.fetchHistory(isRefresh: true),
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // Filter Chip Banner (jika filter aktif)
            if (controller.selectedStartDate.value != null &&
                controller.selectedEndDate.value != null)
              _buildFilterBanner(controller),

            // Content List
            Expanded(
              child: _buildBody(controller, theme),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterBanner(HistoryController controller) {
    final startStr = DateFormat('d MMM yyyy')
        .format(controller.selectedStartDate.value!);
    final endStr =
        DateFormat('d MMM yyyy').format(controller.selectedEndDate.value!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFEFF6FF),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined,
              size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filter: $startStr - $endStr',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E40AF),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.clearFilter(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(HistoryController controller, ThemeData theme) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 56, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                'Terjadi Kesalahan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.fetchHistory(isRefresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Coba Lagi', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.historyList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Belum Ada Riwayat Presensi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Catatan riwayat presensi kerja Anda akan ditampilkan di sini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchHistory(isRefresh: true),
      child: ListView.separated(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: controller.historyList.length +
            (controller.isLoadingMore.value ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == controller.historyList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          final item = controller.historyList[index];
          return _buildHistoryCard(item, controller);
        },
      ),
    );
  }

  Widget _buildHistoryCard(AttendanceRecord item, HistoryController controller) {
    final statusColor = _getStatusColor(item.status?.value);
    final statusLabel = item.status?.label ?? 'Hadir';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tanggal & Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.formatDate(item.date),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Baris Waktu Masuk & Pulang
          Row(
            children: [
              // Waktu Masuk
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          controller.formatTime(item.checkInAt),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Garis Pemisah
              Container(
                height: 32,
                width: 1,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 12),

              // Waktu Pulang
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pulang',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          controller.formatTime(item.checkOutAt),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusValue) {
    switch (statusValue) {
      case 'present':
        return const Color(0xFF10B981); // Hijau
      case 'late':
        return const Color(0xFFF59E0B); // Kuning / Amber
      case 'outside_area':
        return const Color(0xFFEF4444); // Merah
      default:
        return const Color(0xFF2563EB); // Biru
    }
  }

  Future<void> _pickDateRange(
      BuildContext context, HistoryController controller) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: controller.selectedStartDate.value != null &&
              controller.selectedEndDate.value != null
          ? DateTimeRange(
              start: controller.selectedStartDate.value!,
              end: controller.selectedEndDate.value!,
            )
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateFilter(picked.start, picked.end);
    }
  }
}
