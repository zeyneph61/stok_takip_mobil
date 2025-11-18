// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_edit_bottom_sheet.dart';
import './dashboard/dashboard_tab.dart'; // <-- 1. YENİ IMPORT

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentPage = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // API Data
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Pagination variables
  int _currentInventoryPage = 1;
  final int _itemsPerPage = 4;
  // Not: _totalPages'ı Inventory'ye taşımadan önce
  // _products'ın boş olup olmadığını kontrol etmek iyi bir fikir.
  int get _totalPages =>
      _products.isEmpty ? 1 : (_products.length / _itemsPerPage).ceil();

  // KULLANILMAYAN SABİT VERİLER SİLİNDİ

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await ProductService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF0F1F3),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                // 2. DEĞİŞİKLİK BURADA
                child: _currentPage == 'dashboard'
                    ? DashboardTab(
                        isLoading: _isLoading,
                        error: _error,
                        products: _products,
                        onRefresh: _loadProducts,
                      )
                    : _buildInventoryContent(), // Henüz buna dokunmadık
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    // Bu metot burada kalabilir, çünkü genel bir bileşen
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF0F50AA)),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const Text(
            'Stock Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F50AA),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    // Bu metot da burada kalabilir
    return Drawer(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F50AA),
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              icon: Icons.home,
              title: 'Dashboard',
              isActive: _currentPage == 'dashboard',
              onTap: () {
                setState(() {
                  _currentPage = 'dashboard';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.inventory_2,
              title: 'Inventory',
              isActive: _currentPage == 'inventory',
              onTap: () {
                setState(() {
                  _currentPage = 'inventory';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // Bu da burada kalabilir
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1570EF).withAlpha(26) : Colors.transparent,
          
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFF1570EF) : const Color(0xFF5D6679),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    isActive ? const Color(0xFF1570EF) : const Color(0xFF5D6679),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. BURADAN _buildDashboardContent, _buildSummaryCard, _buildApiCategoryTable,
  //    _buildApiProductTable ve _buildCard SİLİNDİ.

  Widget _buildInventoryContent() {
    // BU KISIM ŞİMDİLİK AYNI KALIYOR
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1570EF)),
        ),
      );
    }

    if (_error != null) {
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
                _error!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1570EF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Debug bilgisi göster
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Debug Bilgisi'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('API URL: ${ProductService.baseUrl}'),
                        SizedBox(height: 8),
                        Text('Android Emülatör kullanıyorsanız:'),
                        Text('• API localhost:5000 portundan çalışmalı'),
                        Text('• Emülatörde 10.0.2.2:5000 kullanılır'),
                        SizedBox(height: 8),
                        Text('Fiziksel cihaz kullanıyorsanız:'),
                        Text('• Bilgisayarınızın IP adresini kullanın'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Bağlantı Ayarları',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate pagination for API data
    final startIndex = (_currentInventoryPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _products.length);
    final paginatedProducts = _products.sublist(startIndex, endIndex);

    // Calculate statistics from API data
    final totalProducts = _products.length;
    final lowStockCount = _products
        .where((p) => p.quantity <= p.thresholdValue && p.quantity > 0)
        .length;
    final outOfStockCount = _products.where((p) => p.quantity == 0).length;
    final totalQuantity =
        _products.fold(0, (sum, product) => sum + product.quantity);

    // Calculate unique categories
    final categories = _products.map((p) => p.category).toSet().length;

    return Column(
      children: [
        // Overall Inventory
        _buildCard( // BU METODU BURADA KULLANDIĞIMIZ İÇİN HENÜZ SİLEMEDİK
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
                            width: 1,
                            height: 80,
                            color: const Color(0xFFF0F1F3)),
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
                            width: 1,
                            height: 80,
                            color: const Color(0xFFF0F1F3)),
                        Expanded(
                          child: _buildInventoryStatItem(
                            title: 'Monthly Revenue',
                            value:
                                '₺${(_products.fold(0.0, (sum, product) => sum + (product.sellPrice * product.soldLastMonth))).toStringAsFixed(2)}',
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
        ),
        const SizedBox(height: 16),

        // Products Section
        _buildCard( // BU METODU BURADA KULLANDIĞIMIZ İÇİN HENÜZ SİLEMEDİK
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
                        onPressed: _loadProducts,
                        icon: const Icon(Icons.refresh),
                        color: const Color(0xFF1366D9),
                        tooltip: 'Refresh',
                      ),
                      ElevatedButton(
                        onPressed: () => _showProductEditModal(context),
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
              if (_products.isEmpty)
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
                ...paginatedProducts.map((product) => _buildApiProductCard(product)),

              if (_products.isNotEmpty) ...[
                const SizedBox(height: 16),
                // Pagination Controls
                _buildPaginationControls(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- _buildCard'I BURADA BIRAKTIK ÇÜNKÜ Inventory KISMI DA KULLANIYOR ---
  Widget _buildCard({required Widget child}) {
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
      child: child,
    );
  }

  // --- Inventory KISMINA AİT TÜM YARDIMCI METOTLAR HALA BURADA ---

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Before Button
        TextButton(
          onPressed: _currentInventoryPage > 1
              ? () {
                  setState(() {
                    _currentInventoryPage--;
                  });
                }
              : null,
          style: TextButton.styleFrom(
            foregroundColor: _currentInventoryPage > 1
                ? const Color(0xFF1570EF)
                : const Color(0xFF9CA3AF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: _currentInventoryPage > 1
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
            'Page $_currentInventoryPage / $_totalPages',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),

        // After Button
        TextButton(
          onPressed: _currentInventoryPage < _totalPages
              ? () {
                  setState(() {
                    _currentInventoryPage++;
                  });
                }
              : null,
          style: TextButton.styleFrom(
            foregroundColor: _currentInventoryPage < _totalPages
                ? const Color(0xFF1570EF)
                : const Color(0xFF9CA3AF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: _currentInventoryPage < _totalPages
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

  Widget _buildApiProductCard(Product product) {
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
      onTap: () => _showProductEditModal(context, product),
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

  void _showProductEditModal(BuildContext context, [Product? product]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductEditBottomSheet(
        product: product,
        onProductSaved: () {
          _loadProducts(); // Refresh the product list
        },
      ),
    );
  }
}