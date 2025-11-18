// lib/screens/dashboard/widgets/best_selling_product_card.dart

import 'package:flutter/material.dart';
import '../../../models/product.dart'; // Product modelini import et
import '../../../widgets/common/custom_card.dart'; // Ortak Card'ı import et

class BestSellingProductCard extends StatelessWidget {
  final List<Product> topProducts;

  const BestSellingProductCard({
    super.key,
    required this.topProducts,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best selling product',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F50AA),
            ),
          ),
          const SizedBox(height: 16),
          if (topProducts.isEmpty)
            const Center(
              child: Text(
                'Henüz ürün verisi yok',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667085),
                ),
              ),
            )
          else
            _buildApiProductTable(topProducts),
        ],
      ),
    );
  }

  Widget _buildApiProductTable(List<Product> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 0,
        headingRowHeight: 40,
        dataRowMinHeight: 48,  // <-- YENİ
        dataRowMaxHeight: 48,  // <-- YENİ
        dividerThickness: 1,
        border: TableBorder(
          horizontalInside: BorderSide(color: const Color(0xFFF0F1F3)),
        ),
        columns: const [
          DataColumn(
            label: Text(
              'PRODUCT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF845EBC),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'ID',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE19133),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF36960),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'SOLD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1570EF),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'PROFIT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF845EBC),
              ),
            ),
          ),
        ],
        rows: products.map((product) {
          final profit =
              (product.sellPrice - product.buyingPrice) * product.soldLastMonth;
          return DataRow(
            cells: [
              DataCell(Text(
                product.name,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5D6679),
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                '#${product.id}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5D6679),
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                product.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5D6679),
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                product.soldLastMonth.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF383E49),
                  fontWeight: FontWeight.w600,
                ),
              )),
              DataCell(Text(
                '₺${profit.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF383E49),
                  fontWeight: FontWeight.w600,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}