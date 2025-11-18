// lib/screens/inventory/inventory_tab.dart

import 'package:flutter/material.dart';
import '../../models/product.dart';         // <-- Düzeltilmiş model yolu
import 'widgets/overall_inventory_card.dart'; // <-- EKSİK OLAN
import 'widgets/product_list.dart';


class InventoryTab extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Product> products;
  final int currentInventoryPage;
  final int totalPages;
  final VoidCallback onRefresh;
  final VoidCallback onShowDebugInfo;
  final Function(Product?) onShowProductModal;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  final int _itemsPerPage = 5; // Sayfalama için sabit

  const InventoryTab({
    super.key,
    required this.isLoading,
    this.error,
    required this.products,
    required this.currentInventoryPage,
    required this.totalPages,
    required this.onRefresh,
    required this.onShowDebugInfo,
    required this.onShowProductModal,
    required this.onPreviousPage,
    required this.onNextPage,
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
              'Veri yüklenirken hata oluştu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
                textAlign: TextAlign.center,
              ),
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
            const SizedBox(height: 8),
            TextButton(
              onPressed: onShowDebugInfo,
              child: const Text(
                'Bağlantı Ayarları',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    // --- Hesaplamalar ana widget'ta yapılır ---

    // Sayfalama için
    final startIndex = (currentInventoryPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, products.length);
    final paginatedProducts = products.sublist(startIndex, endIndex);

    // Genel Envanter Kartı için
    final totalProducts = products.length;
    final lowStockCount = products
        .where((p) => p.quantity <= p.thresholdValue && p.quantity > 0)
        .length;
    final outOfStockCount = products.where((p) => p.quantity == 0).length;
    final totalQuantity =
        products.fold(0, (sum, product) => sum + product.quantity);
    final categories = products.map((p) => p.category).toSet().length;
    final monthlyRevenue = products.fold(
        0.0, (sum, p) => sum + (p.sellPrice * p.soldLastMonth));

    // --- Build metodu artık ÇOK TEMİZ ---
    return Column(
      children: [
        // 1. Parça
        OverallInventoryCard(
          categories: categories,
          totalProducts: totalProducts,
          totalQuantity: totalQuantity,
          monthlyRevenue: monthlyRevenue,
          lowStockCount: lowStockCount,
          outOfStockCount: outOfStockCount,
        ),
        const SizedBox(height: 16),

        // 2. Parça
        ProductList(
          products: products,
          paginatedProducts: paginatedProducts,
          currentInventoryPage: currentInventoryPage,
          totalPages: totalPages,
          onRefresh: onRefresh,
          onShowProductModal: onShowProductModal,
          onPreviousPage: onPreviousPage,
          onNextPage: onNextPage,
        ),
      ],
    );
  }

  // --- TÜM _build... METOTLARI ARTIK BU DOSYADA DEĞİL ---
}