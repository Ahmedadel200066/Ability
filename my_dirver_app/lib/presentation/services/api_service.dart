import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ملاحظة: إذا كنت تختبر على محاكي أندرويد استخدم http://10.0.2.2:5000
  static const String baseUrl = "https://your-python-server.com";

  static Future<Map<String, dynamic>> signup(
      String name, String phone, String type) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "user_type": type,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        "status": "error",
        "message": "Connection failed: ${e.toString()}"
      };
    }
  }

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
          "pickup_location": [pLat, pLng],
          "destination_location": [dLat, dLng],
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        "status": "error",
        "message": "Connection failed: ${e.toString()}"
      };
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "status": "error",
        "message": "Server error: ${response.statusCode}"
      };
    }
  }
}
