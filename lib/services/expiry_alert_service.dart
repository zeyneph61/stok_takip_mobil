// lib/services/expiry_alert_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/expiry_alert.dart';

class ExpiryAlertService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/ExpiryAlert';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/ExpiryAlert';
    } else {
      return 'http://localhost:5000/api/ExpiryAlert';
    }
  }

  /// Tüm son kullanma tarihi uyarılarını getirir
  static Future<List<ExpiryAlert>> getExpiryAlerts() async {
    try {
      developer.log('Fetching expiry alerts from: $baseUrl');
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
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        developer.log('Expiry alerts loaded: ${jsonData.length}');
        if (jsonData.isNotEmpty) {
          developer.log('First alert sample: ${jsonData.first}');
        }
        return jsonData.map((json) => ExpiryAlert.fromJson(json)).toList();
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('Error loading expiry alerts: $e');
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
  static Future<List<ExpiryAlert>> getActiveAlerts() async {
    final allAlerts = await getExpiryAlerts();
    return allAlerts.where((alert) => !alert.isResolved).toList();
  }

  /// Süresi dolmuş ürünleri getirir
  static Future<List<ExpiryAlert>> getExpiredAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/expired'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => ExpiryAlert.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expired alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading expired alerts: ${e.toString()}');
    }
  }

  /// Belirli bir ürüne ait uyarıları getirir
  static Future<List<ExpiryAlert>> getAlertsByProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => ExpiryAlert.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load product alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading product alerts: ${e.toString()}');
    }
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
