// lib/screens/inventory/widgets/product_list.dart

import 'package:flutter/material.dart';
import '../../../models/product.dart'; // Product modelini import et
import '../../../widgets/common/custom_card.dart'; // Ortak Card'ı import et

class ProductList extends StatelessWidget {
  final List<Product> products;
  final List<Product> paginatedProducts;
  final int currentInventoryPage;
  final int totalPages;
  final VoidCallback onRefresh;
  final Function(Product?) onShowProductModal;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const ProductList({
    super.key,
    required this.products,
    required this.paginatedProducts,
    required this.currentInventoryPage,
    required this.totalPages,
    required this.onRefresh,
    required this.onShowProductModal,
    required this.onPreviousPage,
    required this.onNextPage,
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
                'Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F50AA),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    color: const Color(0xFF1366D9),
                    tooltip: 'Refresh',
                  ),
                  ElevatedButton(
                    onPressed: () => onShowProductModal(null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1366D9),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Edit Stocks',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Display paginated products from API
          if (products.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Henüz ürün bulunamadı',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
            )
          else
            ...paginatedProducts
                .map((product) => _buildApiProductCard(product, context)),

          if (products.isNotEmpty) ...[
            const SizedBox(height: 16),
            // Pagination Controls
            _buildPaginationControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Before Button
        TextButton(
          onPressed: currentInventoryPage > 1 ? onPreviousPage : null,
          style: TextButton.styleFrom(
            foregroundColor: currentInventoryPage > 1
                ? const Color(0xFF1570EF)
                : const Color(0xFF9CA3AF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: currentInventoryPage > 1
                    ? const Color(0xFF1570EF)
                    : const Color(0xFF9CA3AF),
                width: 1,
              ),
            ),
          ),
          child: const Text(
            'Before',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Page indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            'Page $currentInventoryPage / $totalPages',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),

        // After Button
        TextButton(
          onPressed: currentInventoryPage < totalPages ? onNextPage : null,
          style: TextButton.styleFrom(
            foregroundColor: currentInventoryPage < totalPages
                ? const Color(0xFF1570EF)
                : const Color(0xFF9CA3AF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: currentInventoryPage < totalPages
                    ? const Color(0xFF1570EF)
                    : const Color(0xFF9CA3AF),
                width: 1,
              ),
            ),
          ),
          child: const Text(
            'After',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiProductCard(Product product, BuildContext context) {
    Color getStatusColor(String availability) {
      switch (availability.toLowerCase()) {
        case 'no stock':
          return const Color(0xFFF36960);
        case 'low stock':
          return const Color(0xFFF59E0B);
        case 'on stock':
        case 'in stock':
          return const Color(0xFF10B981);
        default:
          return const Color(0xFF6B7280);
      }
    }

    return GestureDetector(
      onTap: () => onShowProductModal(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF0F1F3)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: #${product.id}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667085),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(product.availability).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.availability,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: getStatusColor(product.availability),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildApiProductRow('NAME', product.name),
            _buildApiProductRow('CATEGORY', product.category),
            _buildApiProductRow('QUANTITY', product.quantity.toString()),
            _buildApiProductRow(
                'BUYING PRICE', '₺${product.buyingPrice.toStringAsFixed(2)}'),
            _buildApiProductRow(
                'SELLING PRICE', '₺${product.sellPrice.toStringAsFixed(2)}'),
            _buildApiProductRow('EXPIRY DATE', _formatDate(product.expiryDate)),
            _buildApiProductRow(
                'SOLD LAST MONTH', product.soldLastMonth.toString(),
                isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildApiProductRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667085),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5D6679),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No expiry';

    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}