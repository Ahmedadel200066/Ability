import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 1. عنوان السيرفر (Base URL)
  // لو بتستخدمي محاكي أندرويد (Emulator) استخدمي: http://10.0.2.2:8000
  // لو بتستخدمي موبايل حقيقي لازم تكتبي الـ IP بتاع جهازك (مثلاً: http://192.168.1.5:8000)
  static const String baseUrl = "http://10.0.2.2:8000";

  // 2. دالة تسجيل مستخدم جديد (Signup)
  static Future<Map<String, dynamic>> signup(
      String name, String phone, String type) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": name,
          "phone_number": phone,
          "user_type": type,
        }),
      );

      // تحويل الرد من JSON لنوع Map عشان فلاتر يفهمه
      return jsonDecode(response.body);
    } catch (e) {
      // في حالة وجود خطأ في الاتصال
      return {"status": "error", "message": "تعذر الاتصال بالسيرفر: $e"};
    }
  }

  // 3. دالة تحديث موقع السائق (Update Location)
  static Future<Map<String, dynamic>> updateLocation(
      int driverId, double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_location"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driver_id": driverId,
          "lat": lat,
          "lng": lng,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // 4. دالة طلب رحلة (Request Ride)
  static Future<Map<String, dynamic>> requestRide({
    required int riderId,
    required double pLat,
    required double pLng,
    required double dLat,
    required double dLng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/request_ride"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rider_id": riderId,
          "pickup_lat": pLat,
          "pickup_lng": pLng,
          "destination_lat": dLat,
          "destination_lng": dLng,
          "vehicle_type": "standard"
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
