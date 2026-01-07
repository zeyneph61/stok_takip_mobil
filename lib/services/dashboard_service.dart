// lib/services/dashboard_service.dart

import 'dart:developer' as developer;
import '../models/product.dart';
import '../models/category.dart';
import '../models/expiry_alert.dart';
import '../models/low_stock_alert.dart';
import '../models/sales_report.dart';
import 'product_service.dart';
import 'category_service.dart';
import 'expiry_alert_service.dart';
import 'low_stock_alert_service.dart';
import 'sales_report_service.dart';

class DashboardStats {
  final int totalQuantity;
  final int totalProducts;
  final int totalCategories;
  final int aboutToExpire;
  final int lowStock;
  final int outOfStock;
  final List<Product> products;
  final List<Category> categories;
  final List<ExpiryAlert> expiryAlerts;
  final List<LowStockAlert> lowStockAlerts;
  final List<SalesReport> topSellingProducts;

  DashboardStats({
    required this.totalQuantity,
    required this.totalProducts,
    required this.totalCategories,
    required this.aboutToExpire,
    required this.lowStock,
    required this.outOfStock,
    required this.products,
    required this.categories,
    required this.expiryAlerts,
    required this.lowStockAlerts,
    required this.topSellingProducts,
  });
}

class DashboardService {
  /// Dashboard için tüm verileri toplu olarak yükler
  static Future<DashboardStats> getDashboardStats() async {
    try {
      developer.log('Loading dashboard stats...');

      // Her API çağrısını ayrı ayrı yap ve hataları handle et
      List<Product> products = [];
      List<Category> categories = [];
      List<ExpiryAlert> expiryAlerts = [];
      List<LowStockAlert> lowStockAlerts = [];
      List<SalesReport> topSellingProducts = [];

      // Products - Zorunlu
      try {
        products = await ProductService.getProducts();
        developer.log('Products loaded: ${products.length}');
      } catch (e) {
        developer.log('Error loading products: $e');
        throw Exception('Ürünler yüklenemedi: ${e.toString()}');
      }

      // Categories - Opsiyonel
      try {
        categories = await CategoryService.getCategories();
        developer.log('Categories loaded: ${categories.length}');
      } catch (e) {
        developer.log('Error loading categories: $e');
        // Kategoriler yüklenemezse boş liste kullan
      }

      // Expiry Alerts - Opsiyonel
      try {
        expiryAlerts = await ExpiryAlertService.getExpiryAlerts();
        developer.log('Expiry alerts loaded: ${expiryAlerts.length}');
      } catch (e) {
        developer.log('Error loading expiry alerts: $e');
        // Uyarılar yüklenemezse boş liste kullan
      }

      // Low Stock Alerts - Opsiyonel
      try {
        lowStockAlerts = await LowStockAlertService.getLowStockAlerts();
        developer.log('Low stock alerts loaded: ${lowStockAlerts.length}');
      } catch (e) {
        developer.log('Error loading low stock alerts: $e');
        // Uyarılar yüklenemezse boş liste kullan
      }

      // Top Selling Products - Opsiyonel
      try {
        topSellingProducts = await SalesReportService.getTopSellingProducts(count: 5);
        developer.log('Top selling products loaded: ${topSellingProducts.length}');
      } catch (e) {
        developer.log('Error loading top selling products: $e');
        // Raporlar yüklenemezse boş liste kullan
      }

      // Metrikleri hesapla
      final totalQuantity =
          products.fold(0, (sum, product) => sum + product.quantity);
      final totalProducts = products.length;
      final totalCategories = categories.length;
      final aboutToExpire =
          expiryAlerts.where((alert) => !alert.isResolved).length;
      final lowStock =
          lowStockAlerts.where((alert) => !alert.isResolved).length;
      final outOfStock = products.where((p) => p.quantity == 0).length;

      developer.log('Dashboard stats loaded successfully');
      developer.log(
          'Products: $totalProducts, Categories: $totalCategories, Low Stock: $lowStock');

      return DashboardStats(
        totalQuantity: totalQuantity,
        totalProducts: totalProducts,
        totalCategories: totalCategories,
        aboutToExpire: aboutToExpire,
        lowStock: lowStock,
        outOfStock: outOfStock,
        products: products,
        categories: categories,
        expiryAlerts: expiryAlerts,
        lowStockAlerts: lowStockAlerts,
        topSellingProducts: topSellingProducts,
      );
    } catch (e) {
      developer.log('Error loading dashboard stats: $e');
      throw Exception('Dashboard verisi yüklenirken hata: ${e.toString()}');
    }
  }

  /// Sadece kategori bazlı satış istatistiklerini hesapla
  static Map<String, Map<String, dynamic>> calculateCategoryStats(
      List<Product> products) {
    final categoryStats = <String, Map<String, dynamic>>{};

    for (final product in products) {
      final categoryName = product.category;
      if (!categoryStats.containsKey(categoryName)) {
        categoryStats[categoryName] = {
          'totalSold': 0,
          'profit': 0.0,
        };
      }
      categoryStats[categoryName]!['totalSold'] += product.soldLastMonth;
      categoryStats[categoryName]!['profit'] +=
          (product.sellPrice - product.buyingPrice) * product.soldLastMonth;
    }

    return categoryStats;
  }
}
