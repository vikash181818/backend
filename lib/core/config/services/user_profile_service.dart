import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

/// Example UserProfile model class
class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final phone;
  final refCode;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.refCode,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      refCode: json['ref_code'],
    );
  }
}

class UserProfileService {
  final TokenManager _tokenManager;

  UserProfileService(this._tokenManager);

  Future<UserProfile> fetchUserProfile(String userId) async {
    final token = await _tokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No valid token found');
    }

    final url = Uri.parse('${Constants.apiUserUrl}/$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      // Note the change here: we pass data['user'] to the fromJson method
      print("userprofile respnose>>>>>>>>>>$data");

      return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      throw Exception(
          'Failed to load user profile. Status code: ${response.statusCode}');
    }
  }
}
