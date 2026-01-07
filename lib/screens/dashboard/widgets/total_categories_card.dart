// lib/screens/dashboard/widgets/total_categories_card.dart

import 'package:flutter/material.dart';
import '../../../models/category.dart';

class TotalCategoriesCard extends StatelessWidget {
  final int totalCategories;
  final List<Category> categories;

  const TotalCategoriesCard({
    super.key,
    required this.totalCategories,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Inventory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F50AA),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1570EF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      totalCategories.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total Categories',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
              if (categories.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Categories:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF667085),
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (var category in categories.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1570EF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF101828),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
