// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'catat_penjualan_page.dart'; 
import 'restock_page.dart';         
import '../viewmodels/barang_viewmodel.dart';
import '../viewmodels/transaksi_viewmodel.dart';
import '../models/transaksi_model.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // --- WARNA TEMA ---
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);
  final Color warningRed = const Color(0xFFD32F2F);
  final Color warningBg = const Color(0xFFFFEBEE);

  @override
  Widget build(BuildContext context) {
    // Memantau perubahan data dari kedua ViewModel
    final barangViewModel = Provider.of<BarangViewModel>(context);
    final transaksiViewModel = Provider.of<TransaksiViewModel>(context);

    // 1. HITUNG DATA REALTIME DARI FIREBASE VIA VIEWMODEL
    int totalJenisBarang = barangViewModel.allBarangRaw.length;
    
    // Menghitung jumlah jenis barang yang stoknya di bawah 20 pcs
    int stokAkanHabis = barangViewModel.allBarangRaw.where((item) => item.stok < 20).length;
    
    // Menghitung akumulasi total nilai aset (Stok x Harga Jual)
    int totalAsetRaw = barangViewModel.allBarangRaw.fold(0, (sum, item) => sum + (item.stok * item.harga));
    String nilaiTotalAset = "Rp $totalAsetRaw"; 

    return Scaffold(
      backgroundColor: backgroundGreen,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            _buildCustomHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. KARTU RINGKASAN (Kini Terhubung Dinamis)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Barang
                      _buildSummaryCard(
                        title: "Total Jenis\nBarang",
                        value: totalJenisBarang.toString(),
                        icon: Icons.inventory_2_outlined,
                        iconColor: primaryGreen,
                        bgColor: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      // Stok Habis (Warning)
                      _buildSummaryCard(
                        title: "Stok Akan\nHabis",
                        value: stokAkanHabis.toString(),
                        icon: Icons.warning_amber_rounded,
                        iconColor: warningRed,
                        bgColor: warningBg,
                      ),
                      const SizedBox(width: 12),
                      // Nilai Aset
                      _buildSummaryCard(
                        title: "Estimasi\nNilai Stok",
                        value: nilaiTotalAset,
                        icon: Icons.monetization_on_outlined,
                        iconColor: Colors.blue[700]!,
                        bgColor: Colors.white,
                        isCurrency: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. AKSI CEPAT
                  _buildSectionTitle("Aksi Cepat"),
                  Row(
                    children: [
                      // TOMBOL 1: CATAT PENJUALAN
                      _buildActionButton(
                        icon: Icons.trending_up_rounded,
                        label: "Catat Penjualan",
                        onTap: () async {
                           final result = await Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const CatatPenjualanPage()),
                           );

                           if (!mounted) return;

                           if (result == true) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: const Text("Penjualan berhasil! Stok berkurang."),
                                 backgroundColor: primaryGreen,
                                 behavior: SnackBarBehavior.floating,
                               ),
                             );
                           }
                        },
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // TOMBOL 2: STOK MASUK (RESTOCK)
                      _buildActionButton(
                        icon: Icons.add_shopping_cart_rounded,
                        label: "Stok Masuk",
                        onTap: () async {
                           final result = await Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const RestockPage()),
                           );

                           if (!mounted) return;

                           if (result == true) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: const Text("Stok berhasil ditambahkan!"),
                                 backgroundColor: primaryGreen,
                                 behavior: SnackBarBehavior.floating,
                               ),
                             );
                           }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. AKTIVITAS TERAKHIR (Sinkronisasi dari Database)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Aktivitas Terakhir", marginBottom: 0),
                      TextButton(
                        onPressed: () {},
                        child: Text("Lihat Semua", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  transaksiViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transaksiViewModel.transaksiList.isNotEmpty
                      ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transaksiViewModel.transaksiList.length > 5 
                            ? 5 
                            : transaksiViewModel.transaksiList.length, // Batasi maks 5 log teratas
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final TransaksiModel item = transaksiViewModel.transaksiList[index];
                          return _buildActivityItem(
                            title: item.title,
                            time: item.date,
                            type: item.type,
                          );
                        },
                      )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Text("Belum ada riwayat aktivitas toko", style: TextStyle(color: Colors.grey))),
                        ),

                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL NOTIFIKASI ---
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 450,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text("Notifikasi Toko", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNotifItem("Stok Menipis!", "Minyak Goreng tersisa 8 liter.", "Baru saja", "alert"),
                  _buildNotifItem("Penjualan", "Omzet hari ini naik 20%.", "1 jam lalu", "info"),
                  _buildNotifItem("Sukses", "Barang baru berhasil ditambahkan.", "5 jam lalu", "success"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildCustomHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: primaryGreen.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60, right: -60, 
            child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)))
          ),
          Positioned(
            bottom: 20, left: -40, 
            child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Halo, selamat pagi!", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text("Toko Saya!", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showNotifications, 
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required IconData icon, required Color iconColor, required Color bgColor, bool isCurrency = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            if (isCurrency) 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rp", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  Text(value.replaceAll("Rp ", ""), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87, letterSpacing: -0.5)),
                ],
              )
            else 
              Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: icon == Icons.warning_amber_rounded ? const Color(0xFFD32F2F) : Colors.black87)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 11, height: 1.2, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
              boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(label, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.left),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({required String title, required String time, required String type}) {
    IconData icon = type == 'add' ? Icons.add_box_rounded : (type == 'update' ? Icons.edit_rounded : Icons.shopping_bag_rounded);
    if(type == 'out' || type == 'alert') icon = Icons.warning_rounded;
    Color iconBg = type == 'in' ? Colors.blue[50]! : (type == 'out' || type == 'alert' ? Colors.red[50]! : backgroundGreen);
    Color iconColor = type == 'in' ? Colors.blue : (type == 'out' || type == 'alert' ? Colors.red : primaryGreen);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double marginBottom = 16}) {
    return Padding(padding: EdgeInsets.only(bottom: marginBottom), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)));
  }

  Widget _buildNotifItem(String title, String message, String time, String type) {
    Color bgColor = (type == "alert") ? const Color(0xFFFFEBEE) : (type == "success") ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD);
    Color iconColor = (type == "alert") ? const Color(0xFFD32F2F) : (type == "success") ? const Color(0xFF2E7D32) : const Color(0xFF1976D2);
    IconData icon = (type == "alert") ? Icons.warning_amber_rounded : (type == "success") ? Icons.check_circle_outline : Icons.info_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 11))]),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
