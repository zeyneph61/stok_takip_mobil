// lib/screens/dashboard/dashboard_tab.dart

import 'package:flutter/material.dart';
import '../../models/product.dart'; // Model importu

// Yeni ayırdığımız widget'ları import ediyoruz
import 'widgets/summary_cards_grid.dart';
import 'widgets/best_selling_category_card.dart';
import 'widgets/best_selling_product_card.dart';

class DashboardTab extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Product> products;
  final VoidCallback onRefresh; // Yenileme butonu için fonksiyon

  const DashboardTab({
    super.key,
    required this.isLoading,
    this.error,
    required this.products,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1570EF)),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Dashboard verisi yüklenirken hata oluştu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF667085),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1570EF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    // --- Hesaplamalar ana widget'ta yapılır ---
    
    // Özet Kartları için hesaplamalar
    final totalProducts = products.length;
    final totalQuantity =
        products.fold(0, (sum, product) => sum + product.quantity);
    final lowStockCount = products
        .where((p) => p.quantity <= p.thresholdValue && p.quantity > 0)
        .length;
    final outOfStockCount = products.where((p) => p.quantity == 0).length;

    // En Çok Satan Ürünler için hesaplama
    final bestSellingProducts = [...products]
      ..sort((a, b) => b.soldLastMonth.compareTo(a.soldLastMonth));
    final topProducts = bestSellingProducts.take(3).toList();

    // En Çok Satan Kategoriler için hesaplama
    final categoryStats = <String, Map<String, dynamic>>{};
    for (final product in products) {
      if (!categoryStats.containsKey(product.category)) {
        categoryStats[product.category] = {
          'totalSold': 0,
          'profit': 0.0,
        };
      }
      categoryStats[product.category]!['totalSold'] += product.soldLastMonth;
      categoryStats[product.category]!['profit'] +=
          (product.sellPrice - product.buyingPrice) * product.soldLastMonth;
    }
    final topCategories = categoryStats.entries.toList()
      ..sort((a, b) =>
          (b.value['profit'] as double).compareTo(a.value['profit'] as double));

    // --- Build metodu artık ÇOK TEMİZ ---
    return Column(
      children: [
        // 1. Parça
        SummaryCardsGrid(
          totalQuantity: totalQuantity,
          totalProducts: totalProducts,
          lowStockCount: lowStockCount,
          outOfStockCount: outOfStockCount,
        ),
        const SizedBox(height: 16),

        // 2. Parça
        BestSellingCategoryCard(
          topCategories: topCategories,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 16),

        // 3. Parça
        BestSellingProductCard(
          topProducts: topProducts,
        ),
      ],
    );
  }

  // --- TÜM _build... METOTLARI ARTIK BU DOSYADA DEĞİL ---
}