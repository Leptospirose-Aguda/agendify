import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCategories() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _userCategories().get();
      if (snapshot.docs.isEmpty) {
        // Primeira vez: persiste as categorias padrão e retorna
        await seedDefaults();
        return CategoryModel.defaults;
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('CategoryService.getCategories error: $e');
      return CategoryModel.defaults;
    }
  }

  /// Salva as categorias padrão no Firestore na primeira vez
  Future<void> seedDefaults() async {
    try {
      final batch = _firestore.batch();
      for (final cat in CategoryModel.defaults) {
        final ref = _userCategories().doc(cat.id);
        batch.set(ref, cat.toJson());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('CategoryService.seedDefaults error: $e');
    }
  }

  Future<void> createCategory(CategoryModel category) async {
    try {
      await _userCategories().doc(category.id).set(category.toJson());
    } catch (e) {
      debugPrint('CategoryService.createCategory error: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _userCategories().doc(category.id).set(category.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('CategoryService.updateCategory error: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _userCategories().doc(categoryId).delete();
    } catch (e) {
      debugPrint('CategoryService.deleteCategory error: $e');
      rethrow;
    }
  }
}
