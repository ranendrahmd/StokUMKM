import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaksi_viewmodel.dart';
import '../models/transaksi_model.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);
  final Color incomeColor = const Color(0xFF2E7D32);
  final Color expenseColor = const Color(0xFFD32F2F);

  String _selectedFilter = "Hari Ini";
  final List<String> _filters = ["Hari Ini", "Minggu Ini", "Bulan Ini"];

  @override
  Widget build(BuildContext context) {
    // 1. KONEKSIKAN KE TRANSAKSI VIEWMODEL SECARA REAL-TIME
    final transaksiViewModel = Provider.of<TransaksiViewModel>(context);
    final transactions = transaksiViewModel.transaksiList;

    // 2. HITUNG TOTAL NOMINAL SECARA INSTAN TANPA REGEX
    int totalMasuk = 0;
    int totalKeluar = 0;

    for (var item in transactions) {
      if (item.type == 'in') {
        totalMasuk += item.amount;
      } else {
        totalKeluar += item.amount;
      }
    }

    return Scaffold(
      backgroundColor: backgroundGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            _buildCustomHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RINGKASAN KEUANGAN DINAMIS
                  Row(
                    children: [
                      _buildFinanceCard("Pemasukan", "Rp $totalMasuk", Icons.arrow_downward_rounded, incomeColor),
                      const SizedBox(width: 12),
                      _buildFinanceCard("Pengeluaran", "Rp $totalKeluar", Icons.arrow_upward_rounded, expenseColor),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // FILTER CHIPS (Komponen Visual)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        bool isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedFilter = filter),
                            selectedColor: primaryGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LIST DAFTAR MUTASI DARI CLOUD FIRESTORE
                  const Text("Riwayat Transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),

                  transaksiViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty 
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada transaksi")))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          // Kirim objek model utuh ke komponen card item
                          return _buildTransactionItem(transactions[index]);
                        },
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

  // --- WIDGET HELPER ---

  Widget _buildCustomHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: primaryGreen.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          Positioned(top: -60, right: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)))),
          Positioned(bottom: 20, left: -40, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Laporan Keuangan", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.print_outlined, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransaksiModel item) {
    bool isIn = item.type == 'in';
    Color amountColor = isIn ? incomeColor : expenseColor;
    IconData icon = isIn ? Icons.shopping_bag_outlined : Icons.local_shipping_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: backgroundGreen, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(item.date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(
            "${isIn ? '+' : '-'} Rp ${item.amount}",
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
