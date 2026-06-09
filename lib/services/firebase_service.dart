import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/barang_model.dart';
import '../models/transaksi_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. FITUR AUTENTIKASI (Sign In & Sign Up)
  // ==========================================

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
    } catch (e) {
      throw Exception("Gagal Daftar: ${e.toString()}");
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
    } catch (e) {
      throw Exception("Gagal Login: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUserEmail => _auth.currentUser?.email;
  
  // Fungsi tambahan untuk mengambil ID Unik Akun yang sedang login
  String get currentUid => _auth.currentUser?.uid ?? '';


  // ==========================================
  // 2. FITUR CRUD BARANG (Per Akun User)
  // ==========================================

  // READ: Hanya mengambil data barang milik user yang sedang login
  Stream<List<BarangModel>> getBarangStream() {
    return _db
        .collection('barang')
        .where('userId', isEqualTo: currentUid) // <-- Kunci penyaringan akun
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BarangModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // CREATE: Tambah Barang Baru dengan menempelkan userId milik akun aktif
  Future<void> tambahBarang(BarangModel barang) async {
    try {
      final data = barang.toMap();
      data['userId'] = currentUid; // <-- Menyimpan ID pemilik akun ke dokumen
      await _db.collection('barang').add(data);
    } catch (e) {
      throw Exception("Gagal tambah barang: $e");
    }
  }

  Future<void> updateStokBarang(String id, int stokBaru) async {
    try {
      await _db.collection('barang').doc(id).update({'stok': stokBaru});
    } catch (e) {
      throw Exception("Gagal update stok: $e");
    }
  }

  Future<void> deleteBarang(String id) async {
    try {
      await _db.collection('barang').doc(id).delete();
    } catch (e) {
      throw Exception("Gagal hapus barang: $e");
    }
  }


  // ==========================================
  // 3. FITUR TRANSAKSI / LAPORAN (Per Akun User)
  // ==========================================

  // READ: Hanya mengambil riwayat transaksi milik user yang sedang login
  Stream<List<TransaksiModel>> getTransaksiStream() {
    return _db
        .collection('transaksi')
        .where('userId', isEqualTo: currentUid) // <-- Kunci penyaringan akun
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransaksiModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // CREATE: Catat Log Transaksi Baru dengan menempelkan userId milik akun aktif
  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    try {
      final data = transaksi.toMap();
      data['userId'] = currentUid; // <-- Menyimpan ID pemilik akun ke dokumen
      await _db.collection('transaksi').add(data);
    } catch (e) {
      throw Exception("Gagal mencatat transaksi: $e");
    }
  }
}