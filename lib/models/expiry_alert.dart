// lib/models/expiry_alert.dart

import 'product.dart';

class ExpiryAlert {
  final int id;
  final int productId;
  final DateTime expiryDate;
  final int daysUntilExpiry;
  final bool isResolved;
  final DateTime? resolvedDate;
  final DateTime alertDate;
  final Product? product;

  ExpiryAlert({
    required this.id,
    required this.productId,
    required this.expiryDate,
    required this.daysUntilExpiry,
    required this.isResolved,
    this.resolvedDate,
    required this.alertDate,
    this.product,
  });

  factory ExpiryAlert.fromJson(Map<String, dynamic> json) {
    return ExpiryAlert(
      id: json['id'] as int,
      productId: json['productId'] as int,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      daysUntilExpiry: json['daysUntilExpiry'] as int,
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
      'expiryDate': expiryDate.toIso8601String(),
      'daysUntilExpiry': daysUntilExpiry,
      'isResolved': isResolved,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'alertDate': alertDate.toIso8601String(),
    };
  }
}
