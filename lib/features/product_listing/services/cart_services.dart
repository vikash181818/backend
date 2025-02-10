// cart_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

class CartService {
  final SecureStorageService secureStorage;

  CartService(this.secureStorage);

  /// If cart doesn't exist, creates one; otherwise increments the quantity.
  /// e.g. POST /api/cart/createOrAddToCart
  Future<void> addToCart({
    required String productId,
    required String productUnitId,
    int quantity = 1,
  }) async {
    final token = await secureStorage.read(TokenManager.tokenKey);
    if (token == null) {
      throw Exception("User is not authenticated.");
    }

    final url = Uri.parse("${Constants.baseUrl}/api/cart/createOrAddToCart");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "productId": productId,
        "productUnitId": productUnitId,
        "quantity": quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add to cart: ${response.body}");
    }
  }

  /// PATCH approach to update a specific cart_details doc
  /// If quantity <= 0, remove item from cart
  /// e.g. PATCH /api/cart/detail/:cartDetailId
  Future<void> patchCartDetail({
    required String cartDetailId,
    required int quantity,
  }) async {
    final token = await secureStorage.read(TokenManager.tokenKey);
    if (token == null) {
      throw Exception("User is not authenticated.");
    }

    final url = Uri.parse("${Constants.baseUrl}/api/cart/detail/$cartDetailId");
    final response = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"quantity": quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to patch cart detail: ${response.body}");
    }
  }

  /// If you still want the “full recalc” approach:
  Future<void> updateCartItemQuantity({
    required String cartId,
    required String productUnitId,
    required int quantity,
  }) async {
    final token = await secureStorage.read(TokenManager.tokenKey);
    if (token == null) {
      throw Exception("User is not authenticated.");
    }

    final url = Uri.parse("${Constants.baseUrl}/api/cart/update_quantity");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cartId": cartId,
        "productUnitId": productUnitId,
        "quantity": quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update cart quantity: ${response.body}");
    }
  }

  /// GET /api/cart/user/cart_details_with_amount
  /// returns a list of cart objects (each has id, amount, details, etc.)
  Future<List<dynamic>> fetchUserCartDetailsWithAmount() async {
    final token = await secureStorage.read(TokenManager.tokenKey);
    if (token == null) {
      throw Exception("User is not authenticated.");
    }

    final url = Uri.parse(
        "${Constants.baseUrl}/api/cart/user/cart_details_with_amount");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to fetch cart details with amount: ${response.body}");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['carts'] as List<dynamic>;
  }

  Future<void> removeCartDetail({
    required String cartDetailId,
    required double lineTotal,
  }) async {
    final token = await secureStorage.read(TokenManager.tokenKey);
    if (token == null) {
      throw Exception("User is not authenticated.");
    }
    final url = Uri.parse("${Constants.baseUrl}/api/cart/detail/$cartDetailId");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "lineTotal": lineTotal.toStringAsFixed(2),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to remove cart detail: ${response.body}");
    }
  }
}
