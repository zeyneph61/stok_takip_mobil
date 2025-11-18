// lib/screens/dashboard/widgets/summary_cards_grid.dart

import 'package:flutter/material.dart';

class SummaryCardsGrid extends StatelessWidget {
  final int totalQuantity;
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;

  const SummaryCardsGrid({
    super.key,
    required this.totalQuantity,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildSummaryCard(
          title: 'Inventory Summary',
          value: totalQuantity.toString(),
          label: 'Quantity in Hand',
          valueColor: const Color(0xFF845EBC),
        ),
        _buildSummaryCard(
          title: 'Product Summary',
          value: totalProducts.toString(),
          label: 'Number of Products',
          valueColor: const Color(0xFFDBA362),
        ),
        _buildSummaryCard(
          title: 'Low Stock',
          value: lowStockCount.toString(),
          label: 'Items Below Threshold',
          valueColor: const Color(0xFFF36960),
        ),
        _buildSummaryCard(
          title: 'Out of Stock',
          value: outOfStockCount.toString(),
          label: '0 Remaining Items',
          valueColor: const Color(0xFF1570EF),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10), // <-- DÜZELTME (0.04 * 255 = 10)
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F50AA),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667085),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}