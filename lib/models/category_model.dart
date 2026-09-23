import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue; // armazena Color.value (int) para serialização

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as String,
        name: map['name'] as String,
        colorValue: map['colorValue'] as int,
      );

  CategoryModel copyWith({String? id, String? name, int? colorValue}) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
      );

  /// Categorias padrão usadas como fallback se o usuário não tiver cadastrado nenhuma
  static List<CategoryModel> get defaults => [
        CategoryModel(id: 'work', name: 'Trabalho', colorValue: Colors.blue.toARGB32()),
        CategoryModel(id: 'personal', name: 'Pessoal', colorValue: Colors.green.toARGB32()),
        CategoryModel(id: 'health', name: 'Saúde', colorValue: Colors.red.toARGB32()),
        CategoryModel(id: 'study', name: 'Estudos', colorValue: Colors.purple.toARGB32()),
        CategoryModel(id: 'other', name: 'Outro', colorValue: Colors.orange.toARGB32()),
      ];
}
