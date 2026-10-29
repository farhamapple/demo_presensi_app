import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Profil Saya',
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
            tooltip: 'Segarkan Profil',
            onPressed: () => controller.loadProfile(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;

        return RefreshIndicator(
          onRefresh: () => controller.loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                // 1. Kartu Header Avatar & Nama
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 46,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage: (user?.avatarUrl != null &&
                                user!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: (user?.avatarUrl == null ||
                                user!.avatarUrl!.isEmpty)
                            ? Icon(
                                Icons.person_rounded,
                                size: 52,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Nama Lengkap
                      Text(
                        user?.name ?? 'Nama Pegawai',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Jabatan
                      Text(
                        user?.jabatan ?? 'Jabatan Pegawai',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Badge Status & Role
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildChip(
                            label: (user?.role ?? 'pegawai').toUpperCase(),
                            bgColor: const Color(0xFFEFF6FF),
                            textColor: const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 8),
                          _buildChip(
                            label: (user?.isActive ?? true)
                                ? 'AKUN AKTIF'
                                : 'TIDAK AKTIF',
                            bgColor: (user?.isActive ?? true)
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF2F2),
                            textColor: (user?.isActive ?? true)
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Data Pegawai (dari API /me)
                _buildSectionHeader('Informasi Pegawai'),
                const SizedBox(height: 10),
                Container(
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
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.badge_outlined,
                        title: 'NIP',
                        value: user?.nip ?? '-',
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: user?.email ?? '-',
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildInfoTile(
                        icon: Icons.business_outlined,
                        title: 'Unit Kerja',
                        value: user?.unitKerja ?? '-',
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildInfoTile(
                        icon: Icons.work_outline_rounded,
                        title: 'Jabatan',
                        value: user?.jabatan ?? '-',
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'No. Handphone / WA',
                        value: user?.phone ?? '-',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Informasi Environment & Server URL (dari .env)
                _buildSectionHeader('Informasi Server & Konfigurasi .env'),
                const SizedBox(height: 10),
                Container(
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
                  child: Column(
                    children: [
                      _buildEnvRow(
                        label: 'Base API URL',
                        value: controller.serverUrl,
                        icon: Icons.link_rounded,
                      ),
                      const Divider(height: 20),
                      _buildEnvRow(
                        label: 'Base Host',
                        value: controller.serverHost,
                        icon: Icons.dns_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 4. Tombol Logout
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoggingOut.value
                          ? null
                          : () => _confirmLogout(context, controller),
                      icon: controller.isLoggingOut.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.logout_rounded, size: 20),
                      label: Text(
                        controller.isLoggingOut.value
                            ? 'Sedang Keluar...'
                            : 'Keluar dari Aplikasi',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF475569)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, ProfileController controller) {
    Get.defaultDialog(
      title: 'Konfirmasi Logout',
      titleStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
      middleText: 'Apakah Anda yakin ingin keluar dari aplikasi Si Presensi?',
      middleTextStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: const Color(0xFF64748B),
      ),
      textConfirm: 'Ya, Keluar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEF4444),
      cancelTextColor: const Color(0xFF64748B),
      radius: 14,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }
}
