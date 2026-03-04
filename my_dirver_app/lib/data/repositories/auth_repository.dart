import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://api.yourapp.com"));

  Future<String> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {"phone": phone, "password": password},
      );

      if (response.statusCode == 200) {
        // نرجع الـ Token الذي أرسله السيرفر
        return response.data['token'];
      } else {
        throw "فشل تسجيل الدخول، تأكد من البيانات";
      }
    } catch (e) {
      throw "حدث خطأ في الاتصال بالسيرفر";
    }
  }
}
