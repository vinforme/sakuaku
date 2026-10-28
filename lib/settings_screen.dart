import 'dart:ui';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Profil Utama (Wireframe 5 - Top)
            _buildProfileGlassCard(),
            const SizedBox(height: 30),

            // Kelompok: Akun & Keamanan
            _buildSectionTitle('Akun & Keamanan'),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.person_outline, 'Informasi Pribadi', const Color(0xFF4DB6AC)),
              _buildSettingsTile(Icons.lock_outline, 'Keamanan & PIN', const Color(0xFF4DB6AC)),
              _buildSettingsTile(Icons.account_balance_wallet_outlined, 'Rekening Terhubung', const Color(0xFF4DB6AC)),
            ]),
            const SizedBox(height: 24),

            // Kelompok: Preferensi
            _buildSectionTitle('Preferensi Aplikasi'),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.notifications_none, 'Notifikasi', const Color(0xFF7986CB)),
              _buildSettingsTile(Icons.dark_mode_outlined, 'Tema Tampilan', const Color(0xFF7986CB)),
              _buildSettingsTile(Icons.language, 'Bahasa', const Color(0xFF7986CB)),
            ]),
            const SizedBox(height: 24),

            // Kelompok: Lainnya
            _buildSectionTitle('Lainnya'),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.help_outline, 'Bantuan & Dukungan', const Color(0xFF90A4AE)),
              _buildSettingsTile(Icons.info_outline, 'Tentang SakuAku', const Color(0xFF90A4AE)),
              _buildLogoutTile(), // Tombol Keluar khusus
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Widget: Kartu Profil (Glassmorphism) ---
  Widget _buildProfileGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF26A69A).withOpacity(0.85),
                const Color(0xFF00897B).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00897B).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.person, size: 35, color: Color(0xFF00695C)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Jane',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'jane@gmail.com',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_square, color: Colors.white),
                onPressed: () {
                  // Aksi edit profil
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: Judul Seksi ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF546E7A),
        ),
      ),
    );
  }

  // --- Widget: Kontainer Kelompok Pengaturan (Glassmorphism) ---
  Widget _buildSettingsGroup(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F8).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
          ),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  // --- Widget: Baris Pengaturan (ListTile Custom) ---
  Widget _buildSettingsTile(IconData icon, String title, Color iconColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF263238),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF90A4AE)),
      onTap: () {
        // Aksi ketika menu diklik
      },
    );
  }

  // --- Widget: Tombol Keluar Khusus (Merah) ---
  Widget _buildLogoutTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.logout, color: Color(0xFFD32F2F), size: 20),
      ),
      title: const Text(
        'Keluar Akun',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD32F2F),
        ),
      ),
      onTap: () {
        // Aksi logout
      },
    );
  }
}