import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://api.yourapp.com",
      connectTimeout: const Duration(seconds: 5),
    ),
  );

  Future<String?> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {
          "phone": phone,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        return response.data['token'];
      }
      return null;
    } on DioException catch (e) {
      throw Exception("Authentication failed: ${e.message}");
    }
  }
}
