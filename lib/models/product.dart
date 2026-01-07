
// ignore_for_file: file_names

import 'category.dart';

class Product {
  final int id;
  final String name;
  final String category; // String olarak da tutuyoruz (backward compatibility)
  final int? categoryId;
  final Category? categoryObject; // Nested category object
  final double buyingPrice;
  final double sellPrice;
  final int quantity;
  final int thresholdValue;
  final String? expiryDate;
  final String availability;
  final int soldLastMonth;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.categoryId,
    this.categoryObject,
    required this.buyingPrice,
    required this.sellPrice,
    required this.quantity,
    required this.thresholdValue,
    this.expiryDate,
    required this.availability,
    required this.soldLastMonth,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Eğer category bir object ise, ondan name'i al
    String categoryName = '';
    int? categoryId;
    Category? categoryObject;
    
    if (json['category'] is Map<String, dynamic>) {
      // Category bir object
      categoryObject = Category.fromJson(json['category'] as Map<String, dynamic>);
      categoryName = categoryObject.name;
      categoryId = categoryObject.id;
    } else if (json['category'] is String) {
      // Category bir string (eski format)
      categoryName = json['category'] as String;
    }
    
    // CategoryId ayrı bir field olarak da gelebilir
    if (json['categoryId'] != null) {
      categoryId = json['categoryId'] as int;
    }
    
    return Product(
      id: json['id'] as int, 
      name: json['name'] as String, 
      category: categoryName, 
      categoryId: categoryId,
      categoryObject: categoryObject,
      buyingPrice: json['buyingPrice'] != null 
          ? (json['buyingPrice'] as num).toDouble() 
          : 0.0, 
      sellPrice: json['sellPrice'] != null 
          ? (json['sellPrice'] as num).toDouble() 
          : 0.0, 
      quantity: json['quantity'] as int? ?? 0, 
      thresholdValue: json['thresholdValue'] as int? ?? 0, 
      expiryDate: json['expiryDate'] as String?, 
      availability: json['availability'] as String? ?? 'Unknown', 
      soldLastMonth: json['soldLastMonth'] as int? ?? 0,
    );
  }
}