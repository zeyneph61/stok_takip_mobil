// lib/screens/stock_movements_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_movement.dart';
import '../services/stock_movement_service.dart';
import '../widgets/common/app_drawer.dart';

class StockMovementsScreen extends StatefulWidget {
  const StockMovementsScreen({super.key});

  @override
  State<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends State<StockMovementsScreen> {
  late Future<List<StockMovement>> _futureMovements;
  bool _isRefreshing = false;
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<StockMovement> _allMovements = [];

  @override
  void initState() {
    super.initState();
    _futureMovements = StockMovementService.getStockMovements();
  }

  Future<void> _refreshMovements() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final movements = await StockMovementService.getStockMovements();
      setState(() {
        _allMovements = movements;
        _futureMovements = Future.value(movements);
        _currentPage = 1; // Reset to first page
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yenileme hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  List<StockMovement> _getPaginatedMovements() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= _allMovements.length) return [];
    
    return _allMovements.sublist(
      startIndex,
      endIndex > _allMovements.length ? _allMovements.length : endIndex,
    );
  }

  int get _totalPages => _allMovements.isEmpty 
      ? 1 
      : (_allMovements.length / _itemsPerPage).ceil();

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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paginatedMovements.length + (_allMovements.isNotEmpty ? 1 : 0), // +1 for pagination
              itemBuilder: (context, index) {
                // Pagination controls at the end
                if (index == paginatedMovements.length) {
                  return _buildPaginationControls();
                }
                
                final movement = paginatedMovements[index];
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
              },
            );
          },
        ),
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
