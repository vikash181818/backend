// lib/features/product_listing/data/services/delivery_charge_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/product_listing/model/delivery_charge_model.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/features/product_listing/model/delivery_charge_model.dart';

class DeliveryChargeService {
  final TokenManager _tokenManager;

  DeliveryChargeService()
      : _tokenManager = TokenManager(SecureStorageService());

  /// Fetches all delivery charges from the API.
  Future<List<DeliveryChargeModel>> fetchDeliveryCharges() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final url = Uri.parse('${Constants.baseUrl}/api/deliveryCharges');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("response of delivery charges>>>>>>>>>>${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body) as List<dynamic>;
      return jsonData
          .map((json) =>
              DeliveryChargeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          "Failed to fetch delivery charges. Status Code: ${response.statusCode}");
    }
  }
}
