// pincode_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/user_profile/model/pincode_model.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/features/user_profile/model/pincode_model.dart';

class PincodeService {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final TokenManager _tokenManager;

  PincodeService() : _tokenManager = TokenManager(SecureStorageService());

  /// Fetch all pincodes
  Future<List<PincodeModel>> getAllPincodes() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/pincode');
    debugPrint("URL for fetching pincodes: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Pincodes fetch response => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        return jsonData
            .map<PincodeModel>((item) => PincodeModel.fromJson(item))
            .toList();
      } else if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map<PincodeModel>((item) => PincodeModel.fromJson(item))
            .toList();
      } else {
        throw Exception("Unexpected response format for pincodes");
      }
    } else {
      debugPrint("Error fetching pincodes: ${response.body}");
      throw Exception("Failed to fetch pincodes");
    }
  }

  /// Fetch pincodes by city ID
  Future<List<PincodeModel>> getPincodeByCityId(String cityId) async {
    print("city Id received for pincode$cityId");

    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/city/$cityId/pincodes');
    debugPrint("URL for fetching pincodes by city ID: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Pincodes by city fetch response => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        return jsonData
            .map<PincodeModel>((item) => PincodeModel.fromJson(item))
            .toList();
      } else if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map<PincodeModel>((item) => PincodeModel.fromJson(item))
            .toList();
      } else {
        throw Exception("Unexpected response format for pincodes by city");
      }
    } else {
      debugPrint("Error fetching pincodes by city: ${response.body}");
      throw Exception("Failed to fetch pincodes by city");
    }
  }

  /// Create a new pincode
  Future<PincodeModel> createPincode(PincodeModel pincode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/pincode');
    final body = pincode.toJson();
    debugPrint("Creating pincode => \$body");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint("Create pincode response => ${response.body}");

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        return PincodeModel.fromJson(data['data']);
      }
      // Some APIs might directly return the created object without "data"
      else {
        return PincodeModel.fromJson(data);
      }
    } else {
      debugPrint("Error creating pincode: ${response.body}");
      throw Exception("Failed to create pincode");
    }
  }

  /// Update an existing pincode
  Future<PincodeModel> updatePincode(PincodeModel pincode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/pincode/${pincode.id}');
    final body = pincode.toJson();
    debugPrint("Updating pincode => $body");

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint("Update pincode response => ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        return PincodeModel.fromJson(data['data']);
      }
      // Some APIs might directly return the updated object without "data"
      else {
        return PincodeModel.fromJson(data);
      }
    } else {
      debugPrint("Error updating pincode: ${response.body}");
      throw Exception("Failed to update pincode");
    }
  }

  /// Delete a pincode
  Future<void> deletePincode(String pincodeId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/pincode/$pincodeId');
    debugPrint("Deleting pincode with ID => $pincodeId");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Delete pincode response => ${response.body}");

    if (response.statusCode != 200) {
      debugPrint("Error deleting pincode: ${response.body}");
      throw Exception("Failed to delete pincode");
    }
  }

  /// Fetch pincode by its ID
  Future<PincodeModel> getPincodeById(String pincodeId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/pincode/$pincodeId');
    debugPrint("URL for fetching pincode by ID: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Pincode by ID fetch response => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] != null) {
        return PincodeModel.fromJson(jsonData['data']);
      }
      // Some APIs might directly return the object without "data"
      else {
        return PincodeModel.fromJson(jsonData);
      }
    } else {
      debugPrint("Error fetching pincode by ID: ${response.body}");
      throw Exception("Failed to fetch pincode by ID");
    }
  }
}
