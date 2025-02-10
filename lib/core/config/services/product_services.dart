import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

class ProductsService {
  final SecureStorageService secureStorageService;

  ProductsService({
    required this.secureStorageService,
  });

  Future<List<dynamic>> fetchProductsByCategory(String url) async {
    // Retrieve Bearer token from TokenManager
    final String? token = await TokenManager(secureStorageService).getToken();
    if (token == null) {
      throw Exception('Authorization token not found');
    }

    // Send GET request
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("data>>>>>>>>>>>>>>>>>\$data");

      if (data is List) {
        return data;
      } else if (data is Map<String, dynamic> && data.containsKey('products')) {
        return data['products'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 404) {
      // If product not found, return an empty list with a message or handle gracefully
      return Future.error('Currently product is not available');
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchProductsWithUnits(String url) async {
    // Retrieve Bearer token from TokenManager
    final String? token = await TokenManager(secureStorageService).getToken();
    if (token == null) {
      throw Exception('Authorization token not found');
    }

    // Send GET request
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("data with units>>>>>>>>>>>>>>>>>\$data");

      if (data is List) {
        return data;
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 404) {
      // If product with units not found, return an empty list or handle gracefully
      return Future.error('Currently product is not available');
    } else {
      throw Exception('Currently product is not available');
    }
  }
}
