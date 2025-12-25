// lib/screens/inventory/widgets/product_list.dart

import 'package:flutter/material.dart';
import '../../../models/product.dart'; // Product modelini import et
import '../../../widgets/common/custom_card.dart'; // Ortak Card'ı import et

class ProductList extends StatefulWidget {
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
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  // Türkçe karakterleri düzgün küçük harfe çeviren yardımcı fonksiyon
  String _turkishToLower(String text) {
    return text
        .replaceAll('I', 'ı')
        .replaceAll('İ', 'i')
        .replaceAll('Ç', 'ç')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ö', 'ö')
        .toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.paginatedProducts;
  }

  @override
  void didUpdateWidget(ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paginatedProducts != widget.paginatedProducts) {
      _filterProducts(_searchController.text);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = widget.paginatedProducts;
      } else {
        final queryLower = _turkishToLower(query);
        // Tüm ürünlerde ara, sadece sayfalanmış ürünlerde değil
        _filteredProducts = widget.products.where((product) {
          return _turkishToLower(product.name).contains(queryLower) ||
              _turkishToLower(product.category).contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh),
                    color: const Color(0xFF1366D9),
                    tooltip: 'Refresh',
                  ),
                  ElevatedButton(
                    onPressed: () => widget.onShowProductModal(null),
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
          // Search Bar
          SizedBox(
            height: 48,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterProducts(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(
                  color: Color(0xFF858D9D),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF858D9D),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _filterProducts('');
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF0F1F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1366D9), width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Display filtered products
          if (_filteredProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
            )
          else
            ..._filteredProducts
                .map((product) => _buildApiProductCard(product, context)),

          if (widget.products.isNotEmpty && _searchController.text.isEmpty) ...[
            const SizedBox(height: 16),
            // Pagination Controls (only show when not searching)
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
          onPressed: widget.currentInventoryPage > 1 ? widget.onPreviousPage : null,
          style: TextButton.styleFrom(
            foregroundColor: widget.currentInventoryPage > 1
                ? const Color(0xFF1570EF)
                : const Color(0xFF9CA3AF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: widget.currentInventoryPage > 1
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
            'Page ${widget.currentInventoryPage} / ${widget.totalPages}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),

        // After Button
        TextButton(
          onPressed: widget.currentInventoryPage < widget.totalPages ? widget.onNextPage : null,
          style: TextButton.styleFrom(
            foregroundColor: widget.currentInventoryPage < widget.totalPages
                ? const Color(0xFF1570EF)
                : const Color(0xFF9CA3AF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: widget.currentInventoryPage < widget.totalPages
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
      onTap: () => widget.onShowProductModal(product),
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