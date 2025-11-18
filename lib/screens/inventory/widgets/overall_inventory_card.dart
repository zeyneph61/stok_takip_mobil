// lib/screens/inventory/widgets/overall_inventory_card.dart

import 'package:flutter/material.dart';
import '../../../widgets/common/custom_card.dart'; // Ortak Card'ı import et

class OverallInventoryCard extends StatelessWidget {
  final int categories;
  final int totalProducts;
  final int totalQuantity;
  final double monthlyRevenue;
  final int lowStockCount;
  final int outOfStockCount;

  const OverallInventoryCard({
    super.key,
    required this.categories,
    required this.totalProducts,
    required this.totalQuantity,
    required this.monthlyRevenue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Inventory',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F50AA),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInventoryStatItem(
                        title: 'Categories',
                        value: categories.toString(),
                        label: 'Total Categories',
                        color: const Color(0xFF1570EF),
                      ),
                    ),
                    Container(
                        width: 1, height: 80, color: const Color(0xFFF0F1F3)),
                    Expanded(
                      child: _buildInventoryStatItem(
                        title: 'Products',
                        value: totalProducts.toString(),
                        label: 'Product Types',
                        color: const Color(0xFFE19133),
                      ),
                    ),
                  ],
                ),
                Container(height: 1, color: const Color(0xFFF0F1F3)),
                Row(
                  children: [
                    Expanded(
                      child: _buildInventoryStatItem(
                        title: 'Total Stock',
                        value: totalQuantity.toString(),
                        label: 'Quantity in Hand',
                        color: const Color(0xFF845EBC),
                      ),
                    ),
                    Container(
                        width: 1, height: 80, color: const Color(0xFFF0F1F3)),
                    Expanded(
                      child: _buildInventoryStatItem(
                        title: 'Monthly Revenue',
                        value: '₺${monthlyRevenue.toStringAsFixed(2)}',
                        label: 'Revenue',
                        color: const Color(0xFFF36960),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    lowStockCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF36960),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Low Stock',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    outOfStockCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1570EF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Out of Stock',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatItem({
    required String title,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}