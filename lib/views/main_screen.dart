import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'barang_page.dart';
import 'laporan_page.dart';
import 'profil_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 
  final Color primaryGreen = const Color(0xFF2E7D32);

  // DAFTAR HALAMAN UTAMA (Semua berada di folder lib/views/)
  final List<Widget> _pages = [
    const BerandaPage(),         // Index 0
    const BarangPage(),          // Index 1
    const LaporanPage(),         // Index 2
    const ProfilPage(),          // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: "Barang"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Laporan"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
        ],
      ),
    );
  }
}