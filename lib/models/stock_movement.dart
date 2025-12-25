// lib/models/stock_movement.dart

import 'product.dart';

class StockMovement {
  final int id;
  final int productId;
  final String movementType; // "In" veya "Out"
  final int quantity;
  final double? totalPrice;
  final DateTime date;
  final Product? product;

  StockMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    this.totalPrice,
    required this.date,
    this.product,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int,
      productId: json['productId'] as int,
      movementType: json['movementType'] as String,
      quantity: json['quantity'] as int,
      totalPrice: json['totalPrice'] != null 
          ? (json['totalPrice'] as num).toDouble() 
          : null,
      date: DateTime.parse(json['date'] as String),
      product: json['product'] != null 
          ? Product.fromJson(json['product'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'movementType': movementType,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': date.toIso8601String(),
    };
  }

  bool get isIn => movementType == 'In';
  bool get isOut => movementType == 'Out';
}
