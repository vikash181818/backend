// import 'package:onlinedukans_user/core/config/services/api_client.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';

import 'package:online_dukans_user/core/config/services/api_client.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    print("signup>>>>>>>>>>${Constants.signupEndpoint}");
    final response = await apiClient.post(Constants.signupEndpoint, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    print("login>>>>>>>>>>${Constants.loginEndpoint}");

    final response = await apiClient.post(Constants.loginEndpoint, data: data);
    return response.data;
  }
}
