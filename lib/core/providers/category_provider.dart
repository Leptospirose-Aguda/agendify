import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._service) {
    loadCategories();
  }

  final CategoryService _service;
  List<CategoryModel> _categories = CategoryModel.defaults;
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    _categories = await _service.getCategories();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _service.createCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _service.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
    await loadCategories();
  }

  /// Retorna a categoria pelo nome (case-insensitive) ou null
  CategoryModel? findByName(String? name) {
    if (name == null) return null;
    try {
      return _categories.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
