// lib/services/stock_movement_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/stock_movement.dart';

class StockMovementService {
  // Web için localhost, Android emülatör için 10.0.2.2
  static String get baseUrl => kIsWeb 
      ? 'http://localhost:5000/api/StockMovement'
      : 'http://10.0.2.2:5000/api/StockMovement';

  /// Tüm stok hareketlerini getirir (en yeni tarih önce)
  static Future<List<StockMovement>> getStockMovements() async {
    try {
      developer.log('Fetching stock movements from: $baseUrl');
      
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
        developer.log('Response body: ${response.body}');
        final List<dynamic> jsonData = jsonDecode(response.body);
        developer.log('Stock movements loaded: ${jsonData.length}');
        
        try {
          return jsonData.map((json) {
            developer.log('Parsing movement: $json');
            return StockMovement.fromJson(json);
          }).toList();
        } catch (e, stackTrace) {
          developer.log('JSON Parse Error: $e');
          developer.log('Stack trace: $stackTrace');
          throw Exception('JSON parse hatası: $e');
        }
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('Error loading stock movements: $e');
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

  /// Yeni stok hareketi ekler (manuel kullanım için)
  static Future<StockMovement> createStockMovement(
      Map<String, dynamic> movementData) async {
    try {
      developer.log('Creating stock movement: ' + jsonEncode(movementData));
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(movementData),
      );

      developer.log('Create response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return StockMovement.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Stock movement creation failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error creating stock movement: $e');
      throw Exception('Error creating stock movement: ${e.toString()}');
    }
  }

  /// Belirli bir ürüne ait stok hareketlerini getirir
  static Future<List<StockMovement>> getMovementsByProduct(int productId) async {
    try {
      final allMovements = await getStockMovements();
      return allMovements.where((m) => m.productId == productId).toList();
    } catch (e) {
      throw Exception('Error loading product movements: ${e.toString()}');
    }
  }
}
