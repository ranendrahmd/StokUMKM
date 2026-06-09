import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- WARNA TEMA ---
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);

  // --- CONTROLLER & FORM STATE ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // State untuk menentukan apakah user sedang di mode Log In atau Sign Up
  bool _isSignUpMode = false;

  // --- FUNGSI SUBMIT AUTHENTICATION ---
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      if (_isSignUpMode) {
        // Eksekusi Pendaftaran Akun Baru ke Firebase
        await authViewModel.register(email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Registrasi Berhasil! Otomatis masuk..."),
            backgroundColor: primaryGreen,
          ),
        );
      } else {
        // Eksekusi Log In Sesi Akun Lama
        await authViewModel.login(email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Selamat Datang Kembali!"),
            backgroundColor: primaryGreen,
          ),
        );
      }
      // Catatan: Setelah login/register sukses, AuthWrapper di main.dart 
      // akan otomatis mendeteksi status user dan memindahkan halaman ke MainScreen.
    } catch (e) {
      // Menangkap pesan error dari Firebase (misal: password salah, email sudah terdaftar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: backgroundGreen,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. LOGO & ICON APLIKASI
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Icon(Icons.storefront_rounded, size: 64, color: primaryGreen),
                ),
                const SizedBox(height: 24),
                
                // TEXT JUDUL
                Text(
                  _isSignUpMode ? "Buat Akun Baru" : "Masuk ke Toko",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
                Text(
                  _isSignUpMode 
                      ? "Daftarkan email Anda untuk mulai mengelola stok" 
                      : "Silakan login untuk mengakses dashboard UMKM",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // 2. FORM CONTAINER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // INPUT EMAIL
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email Toko",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Email tidak boleh kosong!";
                          if (!value.contains("@")) return "Format email tidak valid!";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // INPUT PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Password tidak boleh kosong!";
                          if (value.length < 6) return "Password minimal 6 karakter!";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. TOMBOL AKSI UTAMA (Sign In / Sign Up)
                ElevatedButton(
                  onPressed: authViewModel.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: authViewModel.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _isSignUpMode ? "DAFTAR SEKARANG" : "MASUK APLIKASI",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
                const SizedBox(height: 16),

                // 4. TOGGLE SWITCH MODE
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUpMode = !_isSignUpMode;
                      _formKey.currentState?.reset();
                      _emailController.clear();
                      _passwordController.clear();
                    });
                  },
                  style: TextButton.styleFrom(foregroundColor: primaryGreen),
                  child: Text(
                    _isSignUpMode
                        ? "Sudah punya akun? Masuk di sini"
                        : "Belum punya akun? Daftar gratis di sini",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}