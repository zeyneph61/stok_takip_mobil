// lib/services/category_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoryService {
  static String get baseUrl => kIsWeb 
      ? 'http://localhost:5000/api/Category'
      : 'http://10.0.2.2:5000/api/Category';

  static Future<List<Category>> getCategories() async {
    try {
      developer.log('Fetching categories from: $baseUrl');
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - API sunucusuna bağlanılamıyor');
        },
      );

      developer.log('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        developer.log('Categories loaded: ${jsonData.length}');
        return jsonData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('Error loading categories: $e');
      if (e.toString().contains('Connection refused')) {
        throw Exception(
            'Sunucuya bağlanılamıyor. API sunucusunun çalıştığından emin olun.');
      } else if (e.toString().contains('timeout')) {
        throw Exception(
            'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
      } else {
        throw Exception('Veri yükleme hatası: ${e.toString()}');
      }
    }
  }

  static Future<Category> getCategoryById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Category not found: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading category: ${e.toString()}');
    }
  }

  static Future<Category> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(categoryData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Category creation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: ${e.toString()}');
    }
  }

  static Future<void> updateCategory(int id, Map<String, dynamic> categoryData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(categoryData),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Category update failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating category: ${e.toString()}');
    }
  }

  static Future<void> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Category deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: ${e.toString()}');
    }
  }
}
