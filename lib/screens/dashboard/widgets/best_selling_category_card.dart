// lib/screens/dashboard/widgets/best_selling_category_card.dart

import 'package:flutter/material.dart';
import '../../../widgets/common/custom_card.dart'; // Ortak Card' import et

class BestSellingCategoryCard extends StatelessWidget {
  final List<MapEntry<String, Map<String, dynamic>>> topCategories;
  final VoidCallback onRefresh;

  const BestSellingCategoryCard({
    super.key,
    required this.topCategories,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Best selling category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F50AA),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                color: const Color(0xFF1366D9),
                iconSize: 20,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topCategories.isEmpty)
            const Center(
              child: Text(
                'Henüz kategori verisi yok',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667085),
                ),
              ),
            )
          else
            _buildApiCategoryTable(topCategories.take(3).toList()),
        ],
      ),
    );
  }

  Widget _buildApiCategoryTable(
      List<MapEntry<String, Map<String, dynamic>>> categories) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: const Color(0xFFF0F1F3)),
        bottom: BorderSide(color: const Color(0xFFF0F1F3)),
      ),
      children: [
        TableRow(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF0F1F3))),
          ),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF845EBC),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'PROFIT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE19133),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'TOTAL SOLD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF36960),
                ),
              ),
            ),
          ],
        ),
        ...categories.map((item) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  item.key,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5D6679),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '₺${(item.value['profit'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF383E49),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '${item.value['totalSold']} units',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF383E49),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}