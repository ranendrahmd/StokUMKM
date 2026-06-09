// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/barang_viewmodel.dart';
import '../viewmodels/transaksi_viewmodel.dart';
import '../models/barang_model.dart';
import '../services/firebase_service.dart';

class RestockPage extends StatefulWidget {
  const RestockPage({super.key});

  @override
  State<RestockPage> createState() => _RestockPageState();
}

class _RestockPageState extends State<RestockPage> {
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);

  final TextEditingController _jumlahController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  // MENGGUNAKAN ID (STRING) SEBAGAI VALUE DROPDOWN AGAR ANTI-CRASH
  String? _selectedBarangId;

  // LOGIKA SIMPAN RESTOCK KE FIREBASE
  Future<void> _simpanRestock() async {
    if (_selectedBarangId == null || _jumlahController.text.isEmpty) return;
    
    int jumlah = int.tryParse(_jumlahController.text) ?? 0;
    if (jumlah <= 0) return;

    final barangViewModel = Provider.of<BarangViewModel>(context, listen: false);
    final transaksiViewModel = Provider.of<TransaksiViewModel>(context, listen: false);

    try {
      final selectedBarang = barangViewModel.allBarangRaw.firstWhere((e) => e.id == _selectedBarangId);

      int stokBaru = selectedBarang.stok + jumlah;
      await _firebaseService.updateStokBarang(selectedBarang.id!, stokBaru);

      int estimasiModal = (selectedBarang.harga * 0.8 * jumlah).toInt();

      await transaksiViewModel.catatTransaksiBaru(
        "Restock: ${selectedBarang.nama}",
        estimasiModal,
        "out",
      );

      if (!mounted) return;
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui stok: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final barangViewModel = Provider.of<BarangViewModel>(context);
    final listBarang = barangViewModel.allBarangRaw;

    // Proteksi Pengaman asinkron database
    if (listBarang.isNotEmpty) {
      bool idMasihAda = listBarang.any((element) => element.id == _selectedBarangId);
      if (!idMasihAda) {
        _selectedBarangId = listBarang.first.id;
      }
    }

    // Mencari objek barang aktif berdasarkan ID untuk dibaca teks satuannya
    final currentActiveBarang = listBarang.firstWhere(
      (e) => e.id == _selectedBarangId,
      orElse: () => BarangModel(id: '', nama: '', stok: 0, satuan: '', harga: 0),
    );

    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: AppBar(
        title: const Text("Tambah Stok Masuk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pilih Barang Existing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              
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
                        value: item.id,
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
              const SizedBox(height: 24),
              
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _selectedBarangId != null && currentActiveBarang.id!.isNotEmpty
                        ? "Stok Lama: ${currentActiveBarang.stok} ${currentActiveBarang.satuan}" 
                        : "Stok Lama: -", 
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text("Jumlah Masuk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "Contoh: 10",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryGreen, width: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _simpanRestock,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("UPDATE STOK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}