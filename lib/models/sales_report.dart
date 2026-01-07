// lib/models/sales_report.dart

class SalesReport {
  final int? id;
  final int productId;
  final String productName;
  final String category;
  final int soldLastMonth;
  final double profit;

  SalesReport({
    this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.soldLastMonth,
    required this.profit,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      id: json['id'] as int?,
      productId: json['productId'] as int? ?? json['id'] as int,
      productName: json['productName'] as String? ?? json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      soldLastMonth: json['soldLastMonth'] as int? ?? 0,
      profit: json['profit'] != null 
          ? (json['profit'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'category': category,
      'soldLastMonth': soldLastMonth,
      'profit': profit,
    };
  }
}
