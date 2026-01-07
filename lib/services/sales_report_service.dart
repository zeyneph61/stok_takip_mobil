// lib/services/sales_report_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/sales_report.dart';

class SalesReportService {
  static String get baseUrl => kIsWeb 
      ? 'http://localhost:5000/api/SalesReport'
      : 'http://10.0.2.2:5000/api/SalesReport';

  /// Tüm satış raporlarını getirir
  static Future<List<SalesReport>> getSalesReports() async {
    try {
      developer.log('Fetching sales reports from: $baseUrl');
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
        developer.log('Sales reports loaded: ${jsonData.length}');
        return jsonData.map((json) => SalesReport.fromJson(json)).toList();
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('Error loading sales reports: $e');
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

  /// En çok satan ürünleri getirir
  static Future<List<SalesReport>> getTopSellingProducts({int count = 10}) async {
    try {
      developer.log('Fetching top selling products from: $baseUrl/top-selling?count=$count');
      final response = await http.get(
        Uri.parse('$baseUrl/top-selling?count=$count'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      developer.log('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        developer.log('Top selling products loaded: ${jsonData.length}');
        return jsonData.map((json) => SalesReport.fromJson(json)).toList();
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('Error loading top selling products: $e');
      throw Exception('Veri yükleme hatası: ${e.toString()}');
    }
  }

  /// Aylık satış raporunu getirir
  static Future<List<SalesReport>> getMonthlySalesReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/monthly'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => SalesReport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load monthly report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading monthly report: ${e.toString()}');
    }
  }

  /// Belirli bir ürünün satış raporunu getirir
  static Future<List<SalesReport>> getProductSalesReport(int productId) async {
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
        return jsonData.map((json) => SalesReport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load product report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading product report: ${e.toString()}');
    }
  }

  /// Yıllık satış raporunu getirir
  static Future<List<SalesReport>> getYearlySalesReport(int year) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/yearly/$year'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => SalesReport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load yearly report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading yearly report: ${e.toString()}');
    }
  }
}
