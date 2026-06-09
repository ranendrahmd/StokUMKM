import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  // --- WARNA TEMA ---
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color backgroundGreen = const Color(0xFFF1F8E9);

  // --- CONTROLLER ---
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  // --- DATA ---
  String _selectedSatuan = 'pcs';
  final List<String> _satuanList = ['pcs', 'kg', 'liter', 'botol', 'dus', 'sachet', 'piring', 'gelas'];

  String _selectedKategori = 'Makanan';
  final List<String> _kategoriList = ['Makanan', 'Minuman', 'Sembako', 'Alat Tulis', 'Obat', 'Lainnya'];

  // --- LOGIKA VALIDASI & PENGEMBALIAN DATA ---
  void _simpanBarang() {
    if (_namaController.text.isEmpty ||
        _stokController.text.isEmpty ||
        _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Harap lengkapi semua data barang!"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Konversi string ke integer bersih agar tipenya aman (Type-Safe)
    int? stokInt = int.tryParse(_stokController.text);
    int? hargaInt = int.tryParse(_hargaController.text);

    if (stokInt == null || hargaInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Stok dan Harga harus berupa angka valid!"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Mengembalikan Map data bersih ke BarangPage untuk dieksekusi oleh ViewModel
    Navigator.pop(context, {
      'nama': _namaController.text,
      'stok_int': stokInt,
      'satuan': _selectedSatuan,
      'harga_int': hargaInt,
      'kategori': _selectedKategori,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      body: Column(
        children: [
          // 1. HEADER
          _buildCustomHeader(),

          // 2. FORMULIR
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // UPLOAD FOTO (Visual)
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  color: backgroundGreen,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryGreen.withValues(alpha: 0.3), width: 1.5),
                                ),
                                child: Icon(Icons.add_a_photo_rounded, color: primaryGreen, size: 36),
                              ),
                              Positioned(
                                bottom: -4, right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: primaryGreen, 
                                    shape: BoxShape.circle, 
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(child: Text("Foto Produk", style: TextStyle(color: Colors.grey[500], fontSize: 12))),

                        const SizedBox(height: 24),

                        // INPUT NAMA
                        _buildSectionTitle("Informasi Dasar"),
                        _buildTextField(
                          controller: _namaController,
                          label: "Nama Barang",
                          hint: "Contoh: Kopi Susu",
                          icon: Icons.edit_outlined,
                        ),

                        const SizedBox(height: 20),

                        // KATEGORI (CHIPS)
                        _buildSectionTitle("Kategori"),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _kategoriList.map((kategori) {
                            bool isSelected = _selectedKategori == kategori;
                            return ChoiceChip(
                              label: Text(kategori),
                              selected: isSelected,
                              onSelected: (selected) => setState(() => _selectedKategori = kategori),
                              selectedColor: primaryGreen,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // STOK & HARGA
                        _buildSectionTitle("Detail Stok & Harga"),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                controller: _stokController,
                                label: "Stok Awal",
                                hint: "0",
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Satuan", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedSatuan,
                                        isExpanded: true,
                                        icon: Icon(Icons.keyboard_arrow_down, color: primaryGreen, size: 20),
                                        items: _satuanList.map((String value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))).toList(),
                                        onChanged: (newValue) => setState(() => _selectedSatuan = newValue!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _hargaController,
                          label: "Harga Jual",
                          hint: "0",
                          isNumber: true,
                          prefix: "Rp ",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // TOMBOL SIMPAN
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), 
              blurRadius: 10, 
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: _simpanBarang,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text("SIMPAN BARANG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildCustomHeader() {
    return Container(
      height: 130,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.3), 
            blurRadius: 15, 
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60, right: -60, 
            child: Container(
              width: 200, height: 200, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -40, 
            child: Container(
              width: 120, height: 120, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text("Tambah Barang", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, IconData? icon, bool isNumber = false, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
              prefixText: prefix,
              prefixIcon: icon != null ? Icon(icon, color: Colors.grey[500], size: 20) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}