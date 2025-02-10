// import 'package:dio/dio.dart';

import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dio}) : dio = dio ?? Dio();

  Future<Response> post(String url, {Map<String, dynamic>? data}) {
    return dio.post(url, data: data);
  }

  // Add more methods if needed (e.g. get, put, delete)
}
