import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/barang_viewmodel.dart';
import 'viewmodels/transaksi_viewmodel.dart';
import 'views/main_screen.dart';
import 'views/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UMKM Stock',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
          ),
          useMaterial3: true,
        ),
        // Properti builder membungkus seluruh sistem navigasi global (Overlay Tree)
        builder: (context, child) {
          return Consumer<AuthViewModel>(
            builder: (context, authViewModel, _) {
              // Jika user terdeteksi sudah login, pasang blanket Provider di atas Navigator global
              if (authViewModel.user != null) {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => BarangViewModel()),
                    ChangeNotifierProvider(create: (_) => TransaksiViewModel()),
                  ],
                  child: child!,
                );
              }
              // Jika belum login, biarkan aplikasi berjalan biasa tanpa melahirkan ViewModel
              return child!;
            },
          );
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
        ),
      );
    }

    if (authViewModel.user != null) {
      return const MainScreen();
    } else {
      return const LoginPage();
    }
  }
}