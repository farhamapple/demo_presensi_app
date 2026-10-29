import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'SiAbsen',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            tooltip: 'Perbarui Data',
            onPressed: () => controller.initData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.initData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Profil (Nama & Bagian)
              _buildProfileHeader(controller, theme),
              const SizedBox(height: 16),

              // 2. Tanggal & Jam Sekarang
              _buildDateTimeCard(controller),
              const SizedBox(height: 16),

              // 3. Peta Lokasi (Leaflet)
              _buildLeafletMap(controller),
              const SizedBox(height: 12),

              // 4. Informasi Di Luar / Di Dalam Kantor
              _buildGeofenceInfoBadge(controller),
              const SizedBox(height: 20),

              // 5. Tombol Absen Masuk & Absen Keluar
              _buildAttendanceActionButtons(controller),
              const SizedBox(height: 24),

              // 6. List Absen Hari ini berupa Card
              _buildTodayAttendanceCard(controller),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Widget 1: Header Profil (Nama & Bagian)
  Widget _buildProfileHeader(HomeController controller, ThemeData theme) {
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
      ),
      child: Obx(() {
        final user = controller.user.value;
        return Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_rounded,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Memuat nama...',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.jabatan ?? user?.unitKerja ?? 'Bagian Pegawai',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  if (user?.nip != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      'NIP: ${user!.nip}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Widget 2: Tanggal & Jam Sekarang
  Widget _buildDateTimeCard(HomeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tanggal
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  controller.formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Jam Digital
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.formattedTime,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Widget 3: Peta Leaflet (flutter_map)
  Widget _buildLeafletMap(HomeController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Obx(() {
          final pos = controller.currentPosition.value;
          final office = controller.selectedOffice.value;

          // Lokasi default (Jakarta) jika belum terdeteksi
          final defaultLat = office?.latitude ?? -6.17565;
          final defaultLng = office?.longitude ?? 106.82725;

          final centerLatLng = pos != null
              ? LatLng(pos.latitude, pos.longitude)
              : LatLng(defaultLat, defaultLng);

          return Stack(
            children: [
              FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: centerLatLng,
                  initialZoom: 16.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // OpenStreetMap Tile Layer
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.demo_presensi_app',
                  ),

                  // Circle Radius Kantor
                  if (office != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(office.latitude, office.longitude),
                          radius: office.radiusMeters,
                          useRadiusInMeter: true,
                          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                          borderColor: const Color(0xFF2563EB),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),

                  // Polygon Kantor (jika ada)
                  if (office != null && office.polygonCoordinates.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: office.polygonCoordinates
                              .map((p) => LatLng(p.lat, p.lng))
                              .toList(),
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderColor: const Color(0xFF10B981),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),

                  // Markers
                  MarkerLayer(
                    markers: [
                      // Titik Kantor (Merah)
                      if (office != null)
                        Marker(
                          point: LatLng(office.latitude, office.longitude),
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      // Titik Pengguna (Biru)
                      if (pos != null)
                        Marker(
                          point: LatLng(pos.latitude, pos.longitude),
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Loading GPS Indicator
              if (controller.isLocationLoading.value)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mencari sinyal GPS...',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Tombol Pusatkan ke Lokasi Saya
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton.small(
                  heroTag: 'recenter_gps',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E293B),
                  onPressed: () => controller.fetchCurrentLocation(),
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Widget 4: Informasi Di Luar / Di Dalam Kantor
  Widget _buildGeofenceInfoBadge(HomeController controller) {
    return Obx(() {
      final isInside = controller.isInsideOffice.value;
      final distance = controller.distanceToOffice.value;
      final officeName =
          controller.selectedOffice.value?.name ?? 'Lokasi Kantor';

      final bgColor = isInside ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
      final borderColor =
          isInside ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA);
      final iconColor =
          isInside ? const Color(0xFF059669) : const Color(0xFFDC2626);
      final textColor =
          isInside ? const Color(0xFF065F46) : const Color(0xFF991B1B);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              isInside
                  ? Icons.check_circle_outline_rounded
                  : Icons.warning_amber_rounded,
              color: iconColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isInside ? 'Di Dalam Area Kantor' : 'Di Luar Area Kantor',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Jarak: ${distance.toStringAsFixed(1)} m dari $officeName',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: textColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Widget 5: Button Absen Masuk | Button Absen Keluar
  Widget _buildAttendanceActionButtons(HomeController controller) {
    return Obx(() {
      final today = controller.todayAttendance.value;
      final hasCheckedIn = today?.hasCheckedIn ?? false;
      final hasCheckedOut = today?.hasCheckedOut ?? false;
      final isSubmitting = controller.isSubmitting.value;

      // Status tombol
      final canCheckIn = !hasCheckedIn;
      final canCheckOut = hasCheckedIn && !hasCheckedOut;

      return Row(
        children: [
          // Tombol Absen Masuk
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (canCheckIn && !isSubmitting)
                  ? () => controller.checkIn()
                  : null,
              icon: isSubmitting && canCheckIn
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.login_rounded, size: 20),
              label: Text(
                hasCheckedIn ? 'Sudah Masuk' : 'Absen Masuk',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Absen Keluar (Pulang)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (canCheckOut && !isSubmitting)
                  ? () => controller.checkOut()
                  : null,
              icon: isSubmitting && canCheckOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                hasCheckedOut ? 'Sudah Pulang' : 'Absen Keluar',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    });
  }

  // Widget 6: List Absen Hari ini berupa Card
  Widget _buildTodayAttendanceCard(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Absen Hari Ini',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Obx(() => Text(
                  controller.todayAttendance.value?.data?.date ??
                      'Hari Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.isAttendanceLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final today = controller.todayAttendance.value;
          final record = today?.data;

          if (record == null && !(today?.hasCheckedIn ?? false)) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada catatan presensi hari ini.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan lakukan Absen Masuk saat berada di kantor.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Parse Waktu Masuk & Pulang
          final inTime = _formatIsoTime(record?.checkInAt);
          final outTime = _formatIsoTime(record?.checkOutAt);
          final statusLabel = record?.status?.label ?? 'Tercatat';
          final statusColor = _getStatusColor(record?.status?.value);

          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status Kehadiran',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                const Divider(height: 24),

                // Baris Waktu Masuk & Pulang
                Row(
                  children: [
                    // Masuk
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
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
                                inTime ?? '--:--',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
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
                      height: 36,
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(width: 16),

                    // Pulang
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
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
                                outTime ?? '--:--',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
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

                if (record?.notes != null && record!.notes!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Catatan: ${record.notes}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF475569),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // Helper Format Waktu ISO
  String? _formatIsoTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m WIB';
    } catch (_) {
      return isoString;
    }
  }

  // Helper Warna Status Kehadiran
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
}
