import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

class UnitService {
  final SecureStorageService secureStorageService;

  UnitService({required this.secureStorageService});

  /// e.g. fetchUnitDetails('http://192.168.0.121:3000/api/manageProducts/units/1734356237694');
  /// Returns:
  /// {
  ///   "id": "1734356237694",
  ///   "unit_code": "Gram",
  ///   "unit_name": "500 Gram",
  ///   ...
  /// }
  Future<Map<String, dynamic>> fetchUnitDetails(String url) async {
    final token = await TokenManager(secureStorageService).getToken();
    if (token == null) {
      throw Exception('Authorization token not found');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch unit details: ${response.body}');
    }
  }
}
