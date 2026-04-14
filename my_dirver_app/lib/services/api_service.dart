import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // عنوان السيرفر (اللابتوب بتاعك)
  static const String baseUrl = "http://192.168.100.3:8000";

  // دالة موحدة للتعامل مع الـ Post Requests لتقليل التكرار
  static Future<Map<String, dynamic>> _postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return {"status": "error", "message": "فشل الاتصال بالسيرفر: ${response.statusCode}"};
      }
    } catch (e) {
      print("Exception: $e");
      return {"status": "error", "message": "تأكد من تشغيل سيرفر البايثون واتصالك بنفس الشبكة"};
    }
  }

  // 1. تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> signup(String name, String phone, String type) async {
    return await _postRequest("signup", {
      "full_name": name,
      "phone_number": phone,
      "user_type": type,
    });
  }

  // 2. تحديث موقع السائق (Real-time)
  static Future<Map<String, dynamic>> updateLocation(double lat, double lng) async {
    return await _postRequest("update_location", {
      "lat": lat,
      "lng": lng,
    });
  }

  // 3. طلب رحلة جديدة
  static Future<Map<String, dynamic>> requestRide({
    required double pLat,
    required double pLng,
    required double dLat,
    required double dLng,
  }) async {
    return await _postRequest("request_ride", {
      "pickup_lat": pLat,
      "pickup_lng": pLng,
      "destination_lat": dLat,
      "destination_lng": dLng,
    });
  }
}