// address_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/user_profile/model/address_model.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/features/user_profile/model/address_model.dart';

class AddressService {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final TokenManager _tokenManager;

  AddressService() : _tokenManager = TokenManager(SecureStorageService());

  /// Add a new delivery address
  Future addNewAddress(Map<String, dynamic> address) async {
    debugPrint("Address to add: $address");

    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/user-addresses');
    debugPrint("URL for adding address: $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(address), // Serialize the Map directly
    );

    debugPrint("Add address response => ${response.body}");

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final id = jsonResponse['id'];
      final data = jsonResponse['data'];

      if (id == null || data == null) {
        throw Exception("Invalid response from server");
      }

      // Merge 'id' into 'data'
      data['id'] = id;

      return AddressModel.fromJson(data);
    } else {
      debugPrint("Error adding address: ${response.body}");
      throw Exception("Failed to add address");
    }
  }

  /// Get all addresses for the user
  Future<List<AddressModel>> getAllAddresses() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/user-addresses');
    debugPrint("URL for fetching addresses: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Fetch addresses response => ${response.body}");

    debugPrint("Fetch addresses statuscode => ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map<AddressModel>((item) => AddressModel.fromJson(item))
            .toList();
      } else {
        throw Exception("Unexpected response format for addresses");
      }
    } else {
      debugPrint("Error fetching addresses: ${response.body}");
      throw Exception("Failed to fetch addresses");
    }
  }

  /// Update an existing address by ID
  Future<void> updateAddress(String addressId, AddressModel address) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/user-addresses/$addressId');
    debugPrint("URL for updating address: $url");
    debugPrint("Address to update: ${address.toJson()}");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(address.toJson()),
    );

    debugPrint("Update address response => ${response.body}");

    if (response.statusCode != 200) {
      debugPrint("Error updating address: ${response.body}");
      throw Exception("Failed to update address");
    }
  }

  /// Delete an address by ID
  Future<void> deleteAddress(String addressId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/user-addresses/$addressId');
    debugPrint("URL for deleting address: $url");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Delete address response => ${response.body}");

    if (response.statusCode != 200) {
      debugPrint("Error deleting address: ${response.body}");
      throw Exception("Failed to delete address");
    }
  }

  Future<AddressModel> getAddressById(String addressId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.addressUrl}/user-addresses/$addressId');
    debugPrint("URL for fetching address by ID: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Fetch address by ID response => ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return AddressModel.fromJson(jsonData);
      } catch (e) {
        debugPrint("Error parsing address data: $e");
        throw Exception("Failed to parse address data");
      }
    } else {
      debugPrint("Error fetching address by ID: ${response.body}");
      throw Exception("Failed to fetch address by ID");
    }
  }

  /// Get addresses by user ID
  Future<List<AddressModel>> getAddressesByUserId(String userId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url =
        Uri.parse('${Constants.addressUrl}/user-addresses/user/$userId');
    debugPrint("URL for fetching addresses by user ID: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Fetch addresses by user ID response => ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        return jsonData
            .map<AddressModel>((item) => AddressModel.fromJson(item))
            .toList();
      } else {
        throw Exception("Unexpected response format for addresses by user ID");
      }
    } else if (response.statusCode == 404) {
      debugPrint("No available addresses 404${response.body}");
      throw Exception("Failed to fetch addresses by user ID");
    } else {
      debugPrint("Error fetching addresses by user ID: ${response.body}");
      throw Exception("Failed to fetch addresses by user ID");
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String userId, String addressId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse(
        '${Constants.addressUrl}/user-addresses/$userId/$addressId/default');
    debugPrint("URL for setting default address: $url");

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Set default address response => ${response.body}");

    if (response.statusCode != 200) {
      debugPrint("Error setting default address: ${response.body}");
      throw Exception("Failed to set default address");
    }
  }
}
