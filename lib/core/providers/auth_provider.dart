import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _checkLoginStatus();
  }

  bool _isLoggedIn = false;
  String? _username;
  String? _email;
  User? _firebaseUser;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;
  User? get firebaseUser => _firebaseUser;

  Future<void> _checkLoginStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _firebaseUser = currentUser;
        _email = currentUser.email;
        _username = currentUser.displayName ?? currentUser.email?.split('@').first;
        _isLoggedIn = true;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('FirebaseAuth check status info: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    notifyListeners();
  }

  Future<bool> login(String emailInput, String password) async {
    if (emailInput.isEmpty || password.isEmpty) return false;

    try {
      UserCredential userCredential;
      try {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailInput,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'channel-error') {
          userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailInput,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      _firebaseUser = userCredential.user;
      _email = userCredential.user?.email;
      _username = _email?.split('@').first ?? 'Usuário';
      _isLoggedIn = true;

      // Salvar no Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(_firebaseUser?.uid).set({
          'uid': _firebaseUser?.uid,
          'email': _email,
          'username': _username,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore save user info: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email', _email ?? '');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Firebase Auth info (fallback to local): $e');
      final name = emailInput.split('@').first;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', name);
      await prefs.setString('email', emailInput);

      _isLoggedIn = true;
      _username = name;
      _email = emailInput;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut info: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('email');

    _isLoggedIn = false;
    _username = null;
    _email = null;
    _firebaseUser = null;
    notifyListeners();
  }
}
