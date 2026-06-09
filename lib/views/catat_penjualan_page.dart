// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/barang_viewmodel.dart';
import '../viewmodels/transaksi_viewmodel.dart';
import '../models/barang_model.dart';
import '../services/firebase_service.dart';

class CatatPenjualanPage extends StatefulWidget {
  const CatatPenjualanPage({super.key});

  @override
  State<CatatPenjualanPage> createState() => _CatatPenjualanPageState();
}

class _CatatPenjualanPageState extends State<CatatPenjualanPage> {
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);

  final TextEditingController _jumlahController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService(); 
  
  // MENGGUNAKAN ID (STRING) SEBAGAI VALUE DROPDOWN AGAR ANTI-CRASH
  String? _selectedBarangId;

  // Data Keranjang Belanja
  final List<Map<String, dynamic>> _keranjang = [];
  int _grandTotal = 0;
  int _totalItems = 0;

  // Fungsi Tambah ke Keranjang
  void _tambahKeKeranjang() {
    if (_selectedBarangId == null || _jumlahController.text.isEmpty) return;
    
    // Ambil data list barang terbaru untuk mencari detail objek terpilih
    final listBarang = Provider.of<BarangViewModel>(context, listen: false).allBarangRaw;
    final selectedBarang = listBarang.firstWhere((e) => e.id == _selectedBarangId);

    int jumlah = int.tryParse(_jumlahController.text) ?? 0;
    if (jumlah <= 0) return;

    // Validasi Stok
    if (jumlah > selectedBarang.stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok tidak mencukupi!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      int subtotal = jumlah * selectedBarang.harga;
      _keranjang.add({
        "id": selectedBarang.id,
        "nama": selectedBarang.nama,
        "jumlah": jumlah,
        "harga": selectedBarang.harga,
        "subtotal": subtotal,
        "stok_awal": selectedBarang.stok,
      });
      
      _grandTotal += subtotal; 
      _totalItems += jumlah;
      
      _jumlahController.clear(); 
      FocusScope.of(context).unfocus(); 
    });
  }

  // Fungsi Hapus Item dari Keranjang
  void _hapusDariKeranjang(int index) {
    setState(() {
      _grandTotal -= _keranjang[index]['subtotal'] as int;
      _totalItems -= _keranjang[index]['jumlah'] as int;
      _keranjang.removeAt(index);
    });
  }

  // SIMPAN TRANSAKSI ASLI KE FIREBASE
  Future<void> _simpanTransaksi() async {
    if (_keranjang.isEmpty) return;

    final transaksiViewModel = Provider.of<TransaksiViewModel>(context, listen: false);

    try {
      for (var item in _keranjang) {
        int stokBaru = item['stok_awal'] - item['jumlah'];
        await _firebaseService.updateStokBarang(item['id'], stokBaru);
      }

      await transaksiViewModel.catatTransaksiBaru(
        "Penjualan: $_totalItems Item",
        _grandTotal,
        "in",
      );

      if (!mounted) return;
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memproses transaksi: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final barangViewModel = Provider.of<BarangViewModel>(context);
    final listBarang = barangViewModel.allBarangRaw;

    // Proteksi Pengaman: Jika data dari Firebase masuk, set ID pertama kali secara aman
    if (listBarang.isNotEmpty) {
      bool idMasihAda = listBarang.any((element) => element.id == _selectedBarangId);
      if (!idMasihAda) {
        _selectedBarangId = listBarang.first.id;
      }
    }

    // Cari objek barang aktif saat ini berdasarkan ID yang dipilih untuk info stok & harga di UI
    final currentActiveBarang = listBarang.firstWhere(
      (e) => e.id == _selectedBarangId,
      orElse: () => BarangModel(id: '', nama: '', stok: 0, satuan: '', harga: 0),
    );

    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: AppBar(
        title: const Text("Penjualan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // BAGIAN 1: FORM INPUT BARANG
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Input Barang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50], 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBarangId,
                      isExpanded: true,
                      hint: const Text("Pilih Produk"),
                      items: listBarang.map((BarangModel item) {
                        return DropdownMenuItem<String>(
                          value: item.id, // MENGGUNAKAN ID SEBAGAI VALUE KEY
                          child: Text(item.nama),
                        );
                      }).toList(),
                      onChanged: (String? newId) {
                        if (newId != null) {
                          setState(() {
                            _selectedBarangId = newId;
                          });
                        }
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBarangId != null && currentActiveBarang.id!.isNotEmpty
                                ? "Stok: ${currentActiveBarang.stok} ${currentActiveBarang.satuan}" 
                                : "Stok: -", 
                            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _selectedBarangId != null && currentActiveBarang.id!.isNotEmpty
                                ? "@ Rp ${currentActiveBarang.harga}" 
                                : "@ Rp 0", 
                            style: TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _jumlahController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: "Jumlah",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _tambahKeKeranjang,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.white),
                    )
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // BAGIAN 2: DAFTAR KERANJANG
          Expanded(
            child: _keranjang.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text("Keranjang kosong", style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _keranjang.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _keranjang[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: backgroundGreen, borderRadius: BorderRadius.circular(8)),
                            child: Text("${item['jumlah']}x", style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text("Rp ${item['subtotal']}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _hapusDariKeranjang(index),
                          )
                        ],
                      ),
                    );
                  },
                ),
          ),

          // BAGIAN 3: KALKULASI AKHIR & CHECKOUT
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Item", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("$_totalItems Pcs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Total Bayar", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("Rp $_grandTotal", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 22)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _keranjang.isEmpty ? null : _simpanTransaksi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                      ),
                      child: const Text("KONFIRMASI PENJUALAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}