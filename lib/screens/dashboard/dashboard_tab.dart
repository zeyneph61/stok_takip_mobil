// lib/screens/dashboard/dashboard_tab.dart

import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';

// Yeni ayırdığımız widget'ları import ediyoruz
import 'widgets/summary_cards_grid.dart';
import 'widgets/best_selling_category_card.dart';
import 'widgets/best_selling_product_card.dart';
import 'widgets/total_categories_card.dart';

class DashboardTab extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final DashboardStats? dashboardStats; // Product yerine DashboardStats
  final VoidCallback onRefresh;

  const DashboardTab({
    super.key,
    required this.isLoading,
    this.error,
    this.dashboardStats,
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

    if (dashboardStats == null) {
      return const Center(
        child: Text('Veri bulunamadı'),
      );
    }

    final stats = dashboardStats!;
    final products = stats.products;

    // En Çok Satan Ürünler için hesaplama
    final bestSellingProducts = [...products]
      ..sort((a, b) => b.soldLastMonth.compareTo(a.soldLastMonth));
    final topProducts = bestSellingProducts.take(3).toList();

    // En Çok Satan Kategoriler için hesaplama
    final categoryStats = DashboardService.calculateCategoryStats(products);
    final topCategories = categoryStats.entries.toList()
      ..sort((a, b) =>
          (b.value['profit'] as double).compareTo(a.value['profit'] as double));

    // --- Build metodu artık ÇOK TEMİZ ---
    return Column(
      children: [
        // 1. Parça - Summary Cards
        SummaryCardsGrid(
          totalQuantity: stats.totalQuantity,
          totalProducts: stats.totalProducts,
          totalCategories: stats.totalCategories,
          aboutToExpire: stats.aboutToExpire,
          lowStockCount: stats.lowStock,
          outOfStockCount: stats.outOfStock,
        ),
        const SizedBox(height: 16),

        // 2. Parça - Total Categories (Yeni!)
        TotalCategoriesCard(
          totalCategories: stats.totalCategories,
          categories: stats.categories,
        ),
        const SizedBox(height: 16),

        // 3. Parça - Best Selling Category
        BestSellingCategoryCard(
          topCategories: topCategories,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 16),

        // 4. Parça - Best Selling Product
        BestSellingProductCard(
          topProducts: topProducts,
        ),
      ],
    );
  }
}