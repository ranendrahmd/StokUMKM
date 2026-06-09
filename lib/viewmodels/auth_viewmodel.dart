import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    // Mendengarkan perubahan status login user secara real-time dari Firebase
    _firebaseService.userStream.listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Fungsi Log In
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.signIn(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fungsi Log Up / Register
  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.signUp(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fungsi Log Out
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _firebaseService.signOut();
    _isLoading = false;
    notifyListeners();
  }
}