import 'dart:async';
import 'package:flutter/material.dart';
import '../models/barang_model.dart';
import '../services/firebase_service.dart';

class BarangViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<BarangModel>>? _barangSubscription;

  List<BarangModel> _allBarang = [];
  List<BarangModel> _filteredAndSortedBarang = [];
  String _currentSort = "Default";
  String _searchQuery = "";
  bool _isLoading = true;

  List<BarangModel> get barangList => _filteredAndSortedBarang;
  List<BarangModel> get allBarangRaw => _allBarang;
  String get currentSort => _currentSort;
  bool get isLoading => _isLoading;

  BarangViewModel() {
    // Mendengarkan perubahan data dari Firebase secara Real-time
    _barangSubscription = _firebaseService.getBarangStream().listen((data) {
      _allBarang = data;
      _applyFilterAndSort();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Fungsi mengubah kata kunci pencarian
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilterAndSort();
    notifyListeners();
  }

  // Fungsi mengubah kriteria pengurutan
  void setSortCriteria(String criteria) {
    _currentSort = criteria;
    _applyFilterAndSort();
    notifyListeners();
  }

  // Inti logika bisnis pemrosesan data (Search & Sort)
  void _applyFilterAndSort() {
    List<BarangModel> results = [];
    
    // 1. Jalankan Filter Pencarian
    if (_searchQuery.isEmpty) {
      results = List.from(_allBarang);
    } else {
      results = _allBarang
          .where((item) => item.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Jalankan Logika Pengurutan
    if (_currentSort == "Nama A-Z") {
      results.sort((a, b) => a.nama.compareTo(b.nama));
    } else if (_currentSort == "Nama Z-A") {
      results.sort((a, b) => b.nama.compareTo(a.nama));
    } else if (_currentSort == "Harga Termurah") {
      results.sort((a, b) => a.harga.compareTo(b.harga));
    } else if (_currentSort == "Harga Termahal") {
      results.sort((a, b) => b.harga.compareTo(a.harga));
    } else if (_currentSort == "Stok Terbanyak") {
      results.sort((a, b) => b.stok.compareTo(a.stok));
    } else if (_currentSort == "Stok Terendah") {
      results.sort((a, b) => a.stok.compareTo(b.stok));
    }

    _filteredAndSortedBarang = results;
  }

  // Tambah barang baru langsung ke Cloud Firestore
  Future<void> tambahBarangBaru(String nama, int stok, String satuan, int harga) async {
    final newBarang = BarangModel(nama: nama, stok: stok, satuan: satuan, harga: harga);
    await _firebaseService.tambahBarang(newBarang);
  }

  @override
  void dispose() {
    _barangSubscription?.cancel();
    super.dispose();
  }
}