import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Gerencia dados de perfil do usuário no Firestore: users/{uid}
class UserService {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>>? _userDoc(String uid) =>
      _firestore?.collection('users').doc(uid);

  /// Cria ou atualiza o perfil do usuário no Firestore
  Future<void> upsertProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final doc = _userDoc(uid);
      if (doc == null) return;
      await doc.set({
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

  /// Retorna os dados do perfil do usuário ou null se não existir ou se offline
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final docRef = _userDoc(uid);
      if (docRef == null) return null;
      final doc = await docRef
          .get()
          .timeout(const Duration(seconds: 3));
      return doc.data();
    } catch (e) {
      debugPrint('UserService.getProfile error: $e');
      return null;
    }
  }

  /// Atualiza o displayName do usuário no Firestore e no FirebaseAuth
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.updateDisplayName(displayName);
      await _userDoc(user.uid)?.update({'displayName': displayName});
    } catch (e) {
      debugPrint('UserService.updateDisplayName error: $e');
      rethrow;
    }
  }
}
