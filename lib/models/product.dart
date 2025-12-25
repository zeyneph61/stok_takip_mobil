
// ignore_for_file: file_names

class Product {
  final int id;
  final String name;
  final String category;
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
    required this.buyingPrice,
    required this.sellPrice,
    required this.quantity,
    required this.thresholdValue,
    this.expiryDate,
    required this.availability,
    required this.soldLastMonth,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int, 
      name: json['name'] as String, 
      category: json['category'] as String, 
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