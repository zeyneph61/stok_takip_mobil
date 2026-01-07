// lib/screens/stock_movements_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_movement.dart';
import '../models/category.dart';
import '../services/stock_movement_service.dart';
import '../services/category_service.dart';
import '../widgets/common/app_drawer.dart';

class StockMovementsScreen extends StatefulWidget {
  const StockMovementsScreen({super.key});

  @override
  State<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends State<StockMovementsScreen> {
  late Future<List<StockMovement>> _futureMovements;
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<StockMovement> _allMovements = [];
  List<StockMovement> _filteredMovements = [];
  
  // Filter variables
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = 'All'; // All, In, Out
  int? _selectedCategoryId;
  String _searchQuery = '';
  
  // Categories
  List<Category> _categories = [];
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureMovements = StockMovementService.getStockMovements();
    _loadCategories();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Sessizce hata ver, kategoriler opsiyonel
    }
  }
  
  void _applyFilters() {
    if (_allMovements.isEmpty) return;
    
    List<StockMovement> filtered = List.from(_allMovements);
    
    // Date range filter
    if (_startDate != null) {
      filtered = filtered.where((m) => m.date.isAfter(_startDate!) || m.date.isAtSameMomentAs(_startDate!)).toList();
    }
    if (_endDate != null) {
      final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      filtered = filtered.where((m) => m.date.isBefore(endOfDay) || m.date.isAtSameMomentAs(endOfDay)).toList();
    }
    
    // Type filter
    if (_selectedType != 'All') {
      filtered = filtered.where((m) => m.movementType == _selectedType).toList();
    }
    
    // Category filter
    if (_selectedCategoryId != null) {
      filtered = filtered.where((m) {
        if (m.product?.categoryId != null) {
          return m.product!.categoryId == _selectedCategoryId;
        } else if (m.product?.category != null) {
          // Fallback: string karşılaştırma
          final selectedCategory = _categories.firstWhere(
            (c) => c.id == _selectedCategoryId,
            orElse: () => Category(id: -1, name: ''),
          );
          return m.product!.category == selectedCategory.name;
        }
        return false;
      }).toList();
    }
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final productName = m.product?.name.toLowerCase() ?? '';
        return productName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    setState(() {
      _filteredMovements = filtered;
      _currentPage = 1; // Reset to first page
    });
  }
  
  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = 'All';
      _selectedCategoryId = null;
      _searchQuery = '';
      _searchController.clear();
      _filteredMovements = List.from(_allMovements);
      _currentPage = 1;
    });
  }

  Future<void> _refreshMovements() async {
    try {
      final movements = await StockMovementService.getStockMovements();
      setState(() {
        _allMovements = movements;
        _filteredMovements = List.from(movements);
        _futureMovements = Future.value(movements);
        _currentPage = 1; // Reset to first page
      });
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yenileme hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<StockMovement> _getPaginatedMovements() {
    final dataToUse = _filteredMovements.isEmpty ? _allMovements : _filteredMovements;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= dataToUse.length) return [];
    
    return dataToUse.sublist(
      startIndex,
      endIndex > dataToUse.length ? dataToUse.length : endIndex,
    );
  }

  int get _totalPages {
    final dataToUse = _filteredMovements.isEmpty ? _allMovements : _filteredMovements;
    return dataToUse.isEmpty ? 1 : (dataToUse.length / _itemsPerPage).ceil();
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F3),
      appBar: AppBar(
        title: const Text(
          'Stock Movements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF0F50AA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(currentPage: 'stock_movements'),
      body: RefreshIndicator(
        onRefresh: _refreshMovements,
        child: FutureBuilder<List<StockMovement>>(
          future: _futureMovements,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1366D9),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Color(0xFFDA3E33),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5D6679),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshMovements,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1366D9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Store all movements and update state
            if (_allMovements.isEmpty && snapshot.data!.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _allMovements = snapshot.data!;
                  _filteredMovements = List.from(snapshot.data!);
                });
              });
            }

            final movements = snapshot.data!;
            if (movements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No movements found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Get paginated movements
            final paginatedMovements = _getPaginatedMovements();

            return Column(
              children: [
                // Filter Section
                _buildFilterSection(),
                
                // Movement List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: paginatedMovements.length + ((_filteredMovements.isEmpty ? _allMovements : _filteredMovements).isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Pagination controls at the end
                      if (index == paginatedMovements.length) {
                        return _buildPaginationControls();
                      }
                      
                      final movement = paginatedMovements[index];
                      return _buildMovementCard(movement);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movement History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F50AA),
            ),
          ),
          const SizedBox(height: 16),
          
          // Date Range Row
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Start Date:',
                  value: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'End Date:',
                  value: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Type, Category Row
          Row(
            children: [
              Expanded(
                child: _buildTypeDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Search and Clear Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSearchField(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: _clearFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1366D9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D6679),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF5D6679)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null 
                        ? DateFormat('dd.MM.yyyy').format(value)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 13,
                      color: value != null ? const Color(0xFF383E49) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D6679),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: ['All', 'In', 'Out'].map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type == 'All' ? 'All Types' : type,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedType = newValue;
                  });
                  _applyFilters();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D6679),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _selectedCategoryId,
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Categories', style: TextStyle(fontSize: 13)),
                ),
                ..._categories.map((Category category) {
                  return DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name, style: const TextStyle(fontSize: 13)),
                  );
                }),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _selectedCategoryId = newValue;
                });
                _applyFilters();
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D6679),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search product...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF5D6679)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF1366D9)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1366D9),
              onPrimary: Colors.white,
              onSurface: Color(0xFF383E49),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }
  
  Widget _buildMovementCard(StockMovement movement) {
    final isIn = movement.isIn;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Leading Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIn
                  ? const Color(0xFF10A760).withOpacity(0.1)
                  : const Color(0xFFDA3E33).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIn ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIn
                  ? const Color(0xFF10A760)
                  : const Color(0xFFDA3E33),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  movement.product?.name ?? 'Unknown Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF383E49),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movement.product?.category ?? '',
                  style: const TextStyle(
                    color: Color(0xFF5D6679),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(movement.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Trailing
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${movement.quantity}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isIn
                      ? const Color(0xFF10A760)
                      : const Color(0xFFDA3E33),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isIn
                      ? const Color(0xFF10A760).withOpacity(0.1)
                      : const Color(0xFFDA3E33).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isIn ? 'In' : 'Out',
                  style: TextStyle(
                    color: isIn
                        ? const Color(0xFF10A760)
                        : const Color(0xFFDA3E33),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          TextButton(
            onPressed: _currentPage > 1
                ? () => _goToPage(_currentPage - 1)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: _currentPage > 1
                  ? const Color(0xFF1570EF)
                  : const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: _currentPage > 1
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
          
          // Page Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              'Page $_currentPage / $_totalPages',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          
          // Next Button
          TextButton(
            onPressed: _currentPage < _totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: _currentPage < _totalPages
                  ? const Color(0xFF1570EF)
                  : const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: _currentPage < _totalPages
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
      ),
    );
  }
}
