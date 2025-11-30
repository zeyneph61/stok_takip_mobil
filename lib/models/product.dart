
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
      id: json['id'], 
      name: json['name'], 
      category: json['category'], 
      buyingPrice: (json['buyingPrice'] ).toDouble(), 
      sellPrice: (json['sellPrice'] ).toDouble(), 
      quantity: json['quantity'] , 
      thresholdValue: json['thresholdValue'] , 
      expiryDate: json['expiryDate'], // Bu zaten null olabili
      availability: json['availability'] ?? 'Unknown', // null ise 'Unknown' ata 
      soldLastMonth: json['soldLastMonth'] ?? 0, // null ise 0 at
    );
  }
}