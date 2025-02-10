// state_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/user_profile/model/state_model.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/features/user_profile/model/state_model.dart';

class StateService {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final TokenManager _tokenManager;

  StateService() : _tokenManager = TokenManager(SecureStorageService());

  /// Create a new state
  Future<StateModel> createState(StateModel stateModel) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse(Constants.stateEndpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(stateModel.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final data = jsonData['data'];
      return StateModel.fromJson(data);
    } else {
      debugPrint("Error creating state: ${response.body}");
      throw Exception("Failed to create state");
    }
  }

  /// Get all states
  Future<List<StateModel>> getAllStates() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse(Constants.stateEndpoint);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // If your endpoint directly returns a List
      if (jsonData is List) {
        return jsonData.map<StateModel>((e) => StateModel.fromJson(e)).toList();
      }
      // If your endpoint returns { data: [...] }
      else if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map<StateModel>((e) => StateModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      debugPrint("Error fetching states: ${response.body}");
      throw Exception("Failed to fetch states");
    }
  }

  /// Update an existing state by ID
  Future<void> updateState(String stateId, StateModel stateModel) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    debugPrint("updateState => ID to update: $stateId");

    final url = Uri.parse('${Constants.stateEndpoint}/$stateId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "state": stateModel.state,
        "is_active": stateModel.isActive,
        "created_date": stateModel.createdDate,
        "last_updated_date": stateModel.lastUpdatedDate,
        "createdById": stateModel.createdById,
        "lastUpdatedById": stateModel.lastUpdatedById,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint("Error updating state: ${response.body}");
      throw Exception("Failed to update state");
    }
  }

  /// Delete a state by ID
  Future<void> deleteState(String stateId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse('${Constants.stateEndpoint}/$stateId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      debugPrint("Error deleting state: ${response.body}");
      throw Exception("Failed to delete state");
    }
  }

  /// Get a single state by ID
  Future<StateModel> getStateById(String stateId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    final url = Uri.parse("${Constants.addressUrl}/state/$stateId");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return StateModel.fromJson(jsonData);
    } else {
      debugPrint("Error fetching state by ID: ${response.body}");
      throw Exception("Failed to fetch state by ID");
    }
  }
}
