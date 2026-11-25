import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryService {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userCategories() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      return _firestore?.collection('users').doc(uid).collection('categories');
    } catch (_) {
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final col = _userCategories();
      if (col == null) return CategoryModel.defaults;

      final snapshot = await col
          .get()
          .timeout(const Duration(seconds: 3));

      if (snapshot.docs.isEmpty) {
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

  Future<void> seedDefaults() async {
    try {
      final col = _userCategories();
      final firestore = _firestore;
      if (col == null || firestore == null) return;
      final batch = firestore.batch();
      for (final cat in CategoryModel.defaults) {
        final ref = col.doc(cat.id);
        batch.set(ref, cat.toJson());
      }
      await batch.commit().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('CategoryService.seedDefaults error: $e');
    }
  }

  Future<void> createCategory(CategoryModel category) async {
    try {
      final col = _userCategories();
      if (col == null) return;
      await col.doc(category.id).set(category.toJson()).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('CategoryService.createCategory error: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final col = _userCategories();
      if (col == null) return;
      await col.doc(category.id).set(category.toJson(), SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('CategoryService.updateCategory error: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final col = _userCategories();
      if (col == null) return;
      await col.doc(categoryId).delete().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('CategoryService.deleteCategory error: $e');
    }
  }
}
