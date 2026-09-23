import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Gerencia dados de perfil do usuário no Firestore: users/{uid}
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Cria ou atualiza o perfil do usuário no Firestore
  Future<void> upsertProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _userDoc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName ?? email.split('@').first,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService.upsertProfile error: $e');
    }
  }

  /// Retorna os dados do perfil do usuário ou null se não existir
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final doc = await _userDoc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('UserService.getProfile error: $e');
      return null;
    }
  }

  /// Atualiza o displayName do usuário no Firestore e no FirebaseAuth
  Future<void> updateDisplayName(String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.updateDisplayName(displayName);
      await _userDoc(user.uid).update({'displayName': displayName});
    } catch (e) {
      debugPrint('UserService.updateDisplayName error: $e');
      rethrow;
    }
  }
}
