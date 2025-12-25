// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_edit_bottom_sheet.dart';
import '../widgets/common/app_drawer.dart';
import './dashboard/dashboard_tab.dart';
import './inventory/inventory_tab.dart';

class DashboardScreen extends StatefulWidget {
  final String initialPage;
  
  const DashboardScreen({super.key, this.initialPage = 'dashboard'});

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
  final int _itemsPerPage = 5;
  // Not: _totalPages'ı Inventory'ye taşımadan önce
  // _products'ın boş olup olmadığını kontrol etmek iyi bir fikir.
  int get _totalPages =>
      _products.isEmpty ? 1 : (_products.length / _itemsPerPage).ceil();

  // KULLANILMAYAN SABİT VERİLER SİLİNDİ

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
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
    return AppDrawer(currentPage: _currentPage);
  }

  // 3. BURADAN _buildDashboardContent, _buildSummaryCard, _buildApiCategoryTable,
  //    _buildApiProductTable ve _buildCard SİLİNDİ.

  Widget _buildInventoryContent() {
    return InventoryTab(
      isLoading: _isLoading,
      error: _error,
      products: _products,
      currentInventoryPage: _currentInventoryPage,
      totalPages: _totalPages,
      onRefresh: _loadProducts,
      onShowDebugInfo: _showConnectionInfoDialog,
      onShowProductModal: (product) => _showProductEditModal(context, product),
      onPreviousPage: _handlePreviousPage,
      onNextPage: _handleNextPage,
    );
  }

  void _handlePreviousPage() {
    if (_currentInventoryPage <= 1) return;
    setState(() {
      _currentInventoryPage--;
    });
  }

  void _handleNextPage() {
    if (_currentInventoryPage >= _totalPages) return;
    setState(() {
      _currentInventoryPage++;
    });
  }

  void _showConnectionInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Bilgisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API URL: ${ProductService.baseUrl}'),
            const SizedBox(height: 8),
            const Text('Web kullanıyorsanız:'),
            const Text('• API localhost:5000 kullanılır'),
            const SizedBox(height: 8),
            const Text('Android Emülatör kullanıyorsanız:'),
            const Text('• API localhost:5000 portundan çalışmalı'),
            const Text('• Emülatörde 10.0.2.2:5000 kullanılır'),
            const SizedBox(height: 8),
            const Text('Fiziksel cihaz kullanıyorsanız:'),
            const Text('• Bilgisayarınızın IP adresini kullanın'),
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