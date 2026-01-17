// lib/services/low_stock_alert_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/low_stock_alert.dart';

class LowStockAlertService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/LowStockAlert';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/LowStockAlert';
    } else {
      return 'http://localhost:5000/api/LowStockAlert';
    }
  }

  /// Tüm düşük stok uyarılarını getirir
  static Future<List<LowStockAlert>> getLowStockAlerts() async {
    try {
      developer.log('Fetching low stock alerts from: $baseUrl');
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
        developer.log('Low stock alerts loaded: ${jsonData.length}');
        return jsonData.map((json) => LowStockAlert.fromJson(json)).toList();
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('Error loading low stock alerts: $e');
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

  /// Sadece çözümlenmemiş (aktif) uyarıları getirir
  static Future<List<LowStockAlert>> getActiveAlerts() async {
    final allAlerts = await getLowStockAlerts();
    return allAlerts.where((alert) => !alert.isResolved).toList();
  }

  /// Uyarıyı çözümlenmiş olarak işaretle
  static Future<void> resolveAlert(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id/resolve'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to resolve alert: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error resolving alert: ${e.toString()}');
    }
  }

  /// Yeni uyarıları kontrol et
  static Future<void> checkAlerts() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to check alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking alerts: ${e.toString()}');
    }
  }
}
