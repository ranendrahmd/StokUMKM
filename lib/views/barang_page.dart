import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tambah_barang_page.dart';
import '../viewmodels/barang_viewmodel.dart';
import '../models/barang_model.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);
  final int batasStokAman = 20;

  final TextEditingController _searchController = TextEditingController();

  void _clearSearch() {
    _searchController.clear();
    Provider.of<BarangViewModel>(context, listen: false).setSearchQuery('');
    FocusScope.of(context).unfocus();
  }

  void _showSortOptions() {
    final barangViewModel = Provider.of<BarangViewModel>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Urutkan Barang", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildSortItem("Nama A-Z", Icons.sort_by_alpha, barangViewModel),
                  _buildSortItem("Nama Z-A", Icons.sort_by_alpha_outlined, barangViewModel),
                  const Divider(),
                  _buildSortItem("Harga Termurah", Icons.arrow_downward, barangViewModel),
                  _buildSortItem("Harga Termahal", Icons.arrow_upward, barangViewModel),
                  const Divider(),
                  _buildSortItem("Stok Terbanyak", Icons.inventory_2, barangViewModel),
                  _buildSortItem("Stok Terendah", Icons.inventory_2_outlined, barangViewModel),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 450,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const Padding(padding: EdgeInsets.only(bottom: 16), child: Text("Notifikasi Toko", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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

  void _navigateAndAddBarang() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahBarangPage()),
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      final barangViewModel = Provider.of<BarangViewModel>(context, listen: false);
      
      // Simpan langsung ke Firebase via ViewModel
      await barangViewModel.tambahBarangBaru(
        result['nama'],
        result['stok_int'] ?? 0,
        result['satuan'] ?? 'pcs',
        result['harga_int'] ?? 0,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil menambahkan ${result['nama']}"),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memantau state data barang dari ViewModel
    final barangViewModel = Provider.of<BarangViewModel>(context);

    return Scaffold(
      backgroundColor: backgroundGreen,
      body: Column(
        children: [
          _buildCustomHeader(barangViewModel),
          Expanded(
            child: barangViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : barangViewModel.barangList.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: barangViewModel.barangList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final BarangModel item = barangViewModel.barangList[index];
                          bool stokMenipis = item.stok < batasStokAman;
                          
                          return _buildBarangCard(
                            nama: item.nama,
                            stok: "${item.stok} ${item.satuan}",
                            harga: "Rp ${item.harga}",
                            isLowStock: stokMenipis,
                          );
                        },
                      )
                    : _buildEmptyState(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddBarang,
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text('Barang tidak ditemukan', style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Coba kata kunci lain atau\ntambah barang baru.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 20),
          if (_searchController.text.isNotEmpty)
            TextButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh),
              label: const Text("Reset Pencarian"),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            )
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BarangViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: primaryGreen.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Stack(
        children: [
          Positioned(top: -60, right: -60, child: Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)))),
          Positioned(bottom: 40, left: -40, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Selamat Pagi,", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text("Admin Toko", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.dashboard, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text("Total Jenis Barang", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                      ),
                      // Membaca jumlah total item riil dari database
                      Text("${viewModel.allBarangRaw.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Item", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => viewModel.setSearchQuery(value),
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Cari nama barang...",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(Icons.search, color: primaryGreen),
                            suffixIcon: _searchController.text.isNotEmpty 
                                ? IconButton(onPressed: _clearSearch, icon: const Icon(Icons.close, size: 20, color: Colors.grey)) 
                                : null,
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _showSortOptions,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48, height: 48,
                            alignment: Alignment.center,
                            child: Icon(Icons.tune_rounded, color: primaryGreen),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangCard({required String nama, required String stok, required String harga, required bool isLowStock}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.inventory_2_rounded, color: primaryGreen.withValues(alpha: 0.6), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text("Stok: $stok", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    if (isLowStock) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(6)),
                        child: Text("Menipis", style: TextStyle(color: Colors.red[900], fontSize: 10, fontWeight: FontWeight.w700)),
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 6),
                Text(harga, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortItem(String title, IconData icon, BarangViewModel viewModel) {
    bool isSelected = viewModel.currentSort == title;
    return InkWell(
      onTap: () {
        viewModel.setSortCriteria(title);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryGreen : Colors.grey[600]),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? primaryGreen : Colors.black87)),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: primaryGreen),
          ],
        ),
      ),
    );
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