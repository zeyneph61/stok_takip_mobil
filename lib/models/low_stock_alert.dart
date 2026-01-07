// lib/models/low_stock_alert.dart

import 'product.dart';

class LowStockAlert {
  final int id;
  final int productId;
  final int currentQuantity;
  final int thresholdValue;
  final bool isResolved;
  final DateTime? resolvedDate;
  final DateTime alertDate;
  final Product? product;

  LowStockAlert({
    required this.id,
    required this.productId,
    required this.currentQuantity,
    required this.thresholdValue,
    required this.isResolved,
    this.resolvedDate,
    required this.alertDate,
    this.product,
  });

  factory LowStockAlert.fromJson(Map<String, dynamic> json) {
    return LowStockAlert(
      id: json['id'] as int,
      productId: json['productId'] as int,
      currentQuantity: json['currentQuantity'] as int,
      thresholdValue: json['thresholdValue'] as int,
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedDate: json['resolvedDate'] != null 
          ? DateTime.parse(json['resolvedDate'] as String)
          : null,
      alertDate: DateTime.parse(json['alertDate'] as String),
      product: json['product'] != null 
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'currentQuantity': currentQuantity,
      'thresholdValue': thresholdValue,
      'isResolved': isResolved,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'alertDate': alertDate.toIso8601String(),
    };
  }
}
