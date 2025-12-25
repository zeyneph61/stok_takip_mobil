// lib/widgets/product_edit_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../models/product.dart'; // YENİ IMPORT
import '../services/product_service.dart'; // YENİ IMPORT

// Product Edit Bottom Sheet Widget
class ProductEditBottomSheet extends StatefulWidget {
  final Product? product;
  final VoidCallback onProductSaved;

  const ProductEditBottomSheet({
    super.key,
    this.product,
    required this.onProductSaved,
  });

  @override
  State<ProductEditBottomSheet> createState() => _ProductEditBottomSheetState();
}

class _ProductEditBottomSheetState extends State<ProductEditBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _editFormKey = GlobalKey<FormState>();
  final _addFormKey = GlobalKey<FormState>();

  // Controllers
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _thresholdController = TextEditingController();

  bool _hasExpiryDate = false;
  DateTime? _expiryDate;
  String _availabilityStatus = 'In Stock';
  bool _isLoading = false;
  bool _isSearching = false;
  List<Product> _searchResults = [];
  int? _selectedProductId; // Edit için seçilen ürünün ID'sini tut

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // If editing existing product, populate fields
    if (widget.product != null) {
      _populateFields();
      _selectedProductId = widget.product!.id;
      _tabController.index = 0; // Start with Edit tab
    } else {
      _tabController.index = 1; // Start with Add tab
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _categoryController.text = product.category;
    _buyingPriceController.text = product.buyingPrice.toString();
    _sellingPriceController.text = product.sellPrice.toString();
    _quantityController.text = product.quantity.toString();
    _thresholdController.text = product.thresholdValue.toString();
    _availabilityStatus = product.availability;

    if (product.expiryDate != null) {
      _hasExpiryDate = true;
      _expiryDate = DateTime.parse(product.expiryDate!);
    }
  }

  void _updateAvailabilityStatus() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final threshold = int.tryParse(_thresholdController.text) ?? 0;

    setState(() {
      if (quantity == 0) {
        _availabilityStatus = 'Out of Stock';
      } else if (quantity <= threshold) {
        _availabilityStatus = 'Low Stock';
      } else {
        _availabilityStatus = 'In Stock';
      }
    });
  }

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

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final products = await ProductService.getProducts();
      final filteredProducts = products
          .where((product) {
            final nameLower = _turkishToLower(product.name);
            final queryLower = _turkishToLower(query);
            return nameLower.contains(queryLower);
          })
          .toList();

      setState(() {
        _searchResults = filteredProducts;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectProduct(Product product) {
    _selectedProductId = product.id;
    _nameController.text = product.name;
    _categoryController.text = product.category;
    _buyingPriceController.text = product.buyingPrice.toString();
    _sellingPriceController.text = product.sellPrice.toString();
    _quantityController.text = product.quantity.toString();
    _thresholdController.text = product.thresholdValue.toString();
    _availabilityStatus = product.availability;

    if (product.expiryDate != null) {
      _hasExpiryDate = true;
      _expiryDate = DateTime.parse(product.expiryDate!);
    } else {
      _hasExpiryDate = false;
      _expiryDate = null;
    }

    setState(() {
      _searchResults = [];
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with tabs
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Tab buttons
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF1570EF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF5D6679),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Edit Product'),
                      Tab(text: 'Add Product'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEditTab(),
                _buildAddTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _editFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Product
            const Text(
              'Search Product',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F50AA),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _searchController,
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: 'Type product name to search...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1570EF)),
                          ),
                        ),
                      )
                    : const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1570EF)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),

            // Search Results
            if (_searchResults.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = _searchResults[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${product.category} • Qty: ${product.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          onTap: () => _selectProduct(product),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            ..._buildFormFields(),

            const SizedBox(height: 30),

            // Action Buttons for Edit
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _deleteProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF36960),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Delete Product'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5D6679),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1570EF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Product'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _addFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildFormFields(),

            const SizedBox(height: 30),

            // Action Buttons for Add
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5D6679),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1570EF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Add Product'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // Product Name
      const Text(
        'Product Name',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F50AA),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _nameController,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Product name is required' : null,
        decoration: InputDecoration(
          hintText: 'Enter product name',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1570EF)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      const SizedBox(height: 16),

      // Category
      const Text(
        'Category',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F50AA),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _categoryController,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Category is required' : null,
        decoration: InputDecoration(
          hintText: 'Enter product category',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1570EF)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      const SizedBox(height: 16),

      // Price Row
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buying Price (₺)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F50AA),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _buyingPriceController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  decoration: InputDecoration(
                    hintText: 'Enter buying price',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1570EF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selling Price (₺)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F50AA),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sellingPriceController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  decoration: InputDecoration(
                    hintText: 'Enter selling price',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1570EF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Quantity & Threshold Row
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F50AA),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => _updateAvailabilityStatus(),
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1570EF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Threshold Value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F50AA),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => _updateAvailabilityStatus(),
                  decoration: InputDecoration(
                    hintText: 'Enter threshold value',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1570EF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Availability Status (Auto-calculated)
      const Text(
        'Availability Status',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F50AA),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              _availabilityStatus == 'In Stock'
                  ? Icons.check_circle
                  : _availabilityStatus == 'Low Stock'
                      ? Icons.warning
                      : Icons.cancel,
              color: _availabilityStatus == 'In Stock'
                  ? const Color(0xFF10B981)
                  : _availabilityStatus == 'Low Stock'
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFF36960),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$_availabilityStatus (Auto-calculated)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _availabilityStatus == 'In Stock'
                    ? const Color(0xFF10B981)
                    : _availabilityStatus == 'Low Stock'
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFF36960),
              ),
            ),
            const Spacer(),
            Text(
              'Qty: ${_quantityController.text.isEmpty ? '0' : _quantityController.text} / Threshold: ${_thresholdController.text.isEmpty ? '0' : _thresholdController.text}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Expiry Date Section
      Row(
        children: [
          Checkbox(
            value: _hasExpiryDate,
            onChanged: (value) => setState(() => _hasExpiryDate = value ?? false),
            activeColor: const Color(0xFF1570EF),
          ),
          const Text(
            'This product has an expiry date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F50AA),
            ),
          ),
        ],
      ),

      if (_hasExpiryDate) ...[
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          onTap: _selectExpiryDate,
          decoration: InputDecoration(
            hintText: _expiryDate == null
                ? 'gg.aa.yyyy'
                : '${_expiryDate!.day.toString().padLeft(2, '0')}.${_expiryDate!.month.toString().padLeft(2, '0')}.${_expiryDate!.year}',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            suffixIcon:
                const Icon(Icons.calendar_today, color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1570EF)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    ];
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _addProduct() async {
    if (!_addFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> productData = {
        'name': _nameController.text,
        'category': _categoryController.text,
        'buyingPrice': double.parse(_buyingPriceController.text),
        'sellPrice': double.parse(_sellingPriceController.text),
        'quantity': int.parse(_quantityController.text),
        'thresholdValue': int.parse(_thresholdController.text),
        'availability': _availabilityStatus,
      };
      if (_hasExpiryDate && _expiryDate != null) {
        productData['expiryDate'] = _expiryDate!.toIso8601String();
      }

      await ProductService.createProduct(productData);

      if (mounted) {
        Navigator.pop(context);
        widget.onProductSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün başarıyla eklendi'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: ${e.toString()}'),
            backgroundColor: const Color(0xFFF36960),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProduct() async {
    if (!_editFormKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => const AlertDialog(
          title: Text('Eksik seçim'),
          content: Text('Lütfen güncellemek için önce bir ürün seçin.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    

    try {
      final productData = {
        'id': _selectedProductId,     
        'name': _nameController.text,
        'category': _categoryController.text,
        'buyingPrice': double.parse(_buyingPriceController.text),
        'sellPrice': double.parse(_sellingPriceController.text),
        'quantity': int.parse(_quantityController.text),
        'thresholdValue': int.parse(_thresholdController.text),
        'availability': _availabilityStatus,
        'expiryDate': _hasExpiryDate && _expiryDate != null
            ? _expiryDate!.toIso8601String()
            : null,
      };


      await ProductService.updateProduct(_selectedProductId!, productData);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onProductSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün başarıyla güncellendi'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hata'),
          content: Text('Güncelleme başarısız: ${e.toString()}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct() async {
    if (_selectedProductId == null) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => const AlertDialog(
          title: Text('Eksik seçim'),
          content: Text('Silmek için önce bir ürün seçin.'),
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('"${_nameController.text}" ürününü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF36960)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ProductService.deleteProduct(_selectedProductId!);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onProductSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün başarıyla silindi'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hata'),
          content: Text('Silme başarısız: ${e.toString()}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}