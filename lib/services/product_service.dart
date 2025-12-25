// lib/services/product_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  // Web için localhost, Android emülatör için 10.0.2.2
  static String get baseUrl => kIsWeb 
      ? 'http://localhost:5000/api/Product'
      : 'http://10.0.2.2:5000/api/Product';

  static Future<List<Product>> getProducts() async {
    try {
      developer.log('Fetching products from: $baseUrl');
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
      developer.log('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        developer.log('Products loaded: ${jsonData.length}');
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('Error loading products: $e');
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

  static Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Product creation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating product: ${e.toString()}');
    }
  }

  static Future<void> updateProduct(
      int id, Map<String, dynamic> productData) async {
    try {
      developer.log('UPDATE payload for id=$id: ' + jsonEncode(productData));
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(productData),
      );

      developer.log('UPDATE status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        // 200: body dönebilir; 204: No Content — başarı kabul.
        return;
      } else {
        final body = response.body;
        throw Exception('Product update failed: ${response.statusCode}' + (body.isNotEmpty ? ' - $body' : ''));
      }
    } catch (e) {
      throw Exception('Error updating product: ${e.toString()}');
    }
  }

  static Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Product deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: ${e.toString()}');
    }
  }

  static Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Product fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: ${e.toString()}');
    }
  }
}