class BarangModel {
  final String? id; // ID otomatis dari Firebase nantinya
  final String nama;
  final int stok;
  final String satuan;
  final int harga;

  BarangModel({
    this.id,
    required this.nama,
    required this.stok,
    required this.satuan,
    required this.harga,
  });

  // Mengubah data dari Map (Firebase/JSON) ke Object Dart
  factory BarangModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BarangModel(
      id: documentId,
      nama: map['nama'] ?? '',
      stok: map['stok'] ?? 0,
      satuan: map['satuan'] ?? 'pcs',
      harga: map['harga'] ?? 0,
    );
  }

  // Mengubah Object Dart ke Map untuk disimpan ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'stok': stok,
      'satuan': satuan,
      'harga': harga,
    };
  }
}