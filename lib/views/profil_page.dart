import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);

  // Nama user kita buat lokal dulu (bisa dimodifikasi via dialog)
  String _namaUser = "Admin Toko";

  void _showEditProfileDialog() {
    TextEditingController namaController = TextEditingController(text: _namaUser);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama Lengkap", icon: Icon(Icons.person)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _namaUser = namaController.text;
                });
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text("Profil berhasil diperbarui!"), backgroundColor: primaryGreen),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // FUNGSI LOGOUT ASLI (Terhubung ke Firebase via Provider)
  void _handleLogout() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await authViewModel.logout(); // Picu fungsi logout Firebase
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Anda telah berhasil keluar.")),
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user aktif dari AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context);
    final String emailUserAktif = authViewModel.user?.email ?? "Tidak ada sesi user";

    return Scaffold(
      backgroundColor: backgroundGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER + FOTO PROFIL
            Stack(
              clipBehavior: Clip.none, 
              alignment: Alignment.center,
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: primaryGreen.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -50, right: -50, child: _buildCircleDeco(200)),
                      Positioned(bottom: 20, left: -40, child: _buildCircleDeco(100)),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: const Text(
                              "Profil Saya",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: -60,
                  child: Container(
                    padding: const EdgeInsets.all(4), 
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, size: 80, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70), 

            // 2. INFO USER ASLI DARI FIREBASE
            Text(
              _namaUser,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              emailUserAktif, // <-- Email Dinamis asli dari Firebase Auth
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // 3. TOMBOL EDIT PROFIL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit Nama"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 4. MENU PENGATURAN
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.settings_outlined, "Pengaturan Akun"),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.notifications_outlined, "Notifikasi"),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.help_outline, "Pusat Bantuan"),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.info_outline, "Tentang Aplikasi"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL KELUAR ASLI
            TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Keluar Akun", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleDeco(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF2E7D32)), 
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Menu $title diklik (Demo)")),
        );
      },
    );
  }
}