import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String baseUrl = "http://10.0.2.2:5000/api/Product";

  // GET ALL PRODUCTS
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Ürünler alınamadı: ${response.statusCode}");
    }
  }

  // CREATE PRODUCT
  static Future<void> createProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Ürün eklenemedi: ${response.body}");
    }
  }

  // UPDATE PRODUCT
static Future<void> updateProduct(int id, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse("$baseUrl/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  print("UPDATE STATUS CODE: ${response.statusCode}");
  print("UPDATE RESPONSE BODY: ${response.body}");

  // Backend 204 döndürüyor → Bu başarılıdır
  if (response.statusCode == 200 || response.statusCode == 204) {
    return; // BAŞARILI
  }

  throw Exception("Product update failed: ${response.statusCode}");
}



  // DELETE PRODUCT
  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
  throw Exception("Product update failed: ${response.statusCode}");
    }

  }
}
