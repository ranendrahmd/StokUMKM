import 'dart:async';
import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';
import '../services/firebase_service.dart';

class TransaksiViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<TransaksiModel>>? _transaksiSubscription;

  List<TransaksiModel> _transaksiList = [];
  bool _isLoading = true;

  List<TransaksiModel> get transaksiList => _transaksiList;
  bool get isLoading => _isLoading;

  TransaksiViewModel() {
    // Mendengarkan riwayat transaksi dari Firebase secara Real-time
    _transaksiSubscription = _firebaseService.getTransaksiStream().listen((data) {
      // Mengurutkan dari yang terbaru berdasarkan ID atau timestamps (opsional)
      _transaksiList = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Fungsi menambah log transaksi baru
  Future<void> catatTransaksiBaru(String title, int amount, String type) async {
    final newTransaksi = TransaksiModel(
      title: title,
      date: "Baru saja", // Dapat disesuaikan dengan DateTime format riil jika dibutuhkan
      amount: amount,
      type: type,
    );
    await _firebaseService.tambahTransaksi(newTransaksi);
  }

  @override
  void dispose() {
    _transaksiSubscription?.cancel();
    super.dispose();
  }
}