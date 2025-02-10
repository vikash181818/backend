// city_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/user_profile/model/city_model.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';

// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/features/user_profile/model/city_model.dart';

class CityService {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final TokenManager _tokenManager;

  CityService() : _tokenManager = TokenManager(SecureStorageService());

  Future<List<CityModel>> getAllCities() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse("${Constants.addressUrl}/city");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("All cities >>>>>>>>> ${response.body}");
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        return jsonData.map<CityModel>((e) => CityModel.fromJson(e)).toList();
      } else if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map<CityModel>((e) => CityModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      debugPrint("Error fetching cities: ${response.body}");
      throw Exception("Failed to fetch cities");
    }
  }

  Future<CityModel> createCity(CityModel city) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse("${Constants.addressUrl}/city");
    debugPrint("City to add >>>>>>>>> ${city.toJson()}");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(city.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'];
      return CityModel.fromJson(data);
    } else {
      debugPrint("Error creating city: ${response.body}");
      throw Exception("Failed to create city");
    }
  }

  Future<void> updateCity(String cityId, CityModel city) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse("${Constants.addressUrl}/city/$cityId");
    debugPrint("Updating city => $cityId => ${city.toJson()}");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(city.toJson()),
    );

    if (response.statusCode != 200) {
      debugPrint("Error updating city: ${response.body}");
      throw Exception("Failed to update city");
    }
  }

  Future<void> deleteCity(String cityId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    debugPrint("CityId to delete >>>>>>>>> $cityId");
    debugPrint("Token to delete >>>>>>>>> $token");

    final url = Uri.parse("${Constants.addressUrl}/city/$cityId");
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      debugPrint("Error deleting city: ${response.body}");
      throw Exception("Failed to delete city");
    }
  }

  Future<List<CityModel>> getCitiesByStateId(String stateId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse("${Constants.addressUrl}/state/$stateId/cities");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("Cities fetch response => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        return jsonData
            .map<CityModel>((item) => CityModel.fromJson(item))
            .toList();
      } else if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map<CityModel>((item) => CityModel.fromJson(item))
            .toList();
      } else {
        throw Exception("Unexpected response format for cities");
      }
    } else {
      debugPrint("Error fetching cities: ${response.body}");
      throw Exception("Failed to fetch cities");
    }
  }

  Future<CityModel> getCityByCityId(String cityId) async {
    debugPrint("cityId>>>>>>>>>>>>>>> $cityId");
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse("${Constants.addressUrl}/city/cityId/$cityId");
    debugPrint("URL city name >>>>>>>>>>>>>>> ${url.toString()}");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("City fetch response => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is Map<String, dynamic>) {
        return CityModel.fromJson(jsonData);
      } else {
        throw Exception("Unexpected response format for city");
      }
    } else {
      debugPrint("Error fetching city by cityId: ${response.body}");
      throw Exception("Failed to fetch city by cityId");
    }
  }
}
