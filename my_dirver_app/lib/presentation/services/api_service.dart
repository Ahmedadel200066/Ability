import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Mock constant to simulate a backend response
  static const bool useMock = true;

  static Future<Map<String, dynamic>> signup(
      String name, String phone, String type) async {
    if (useMock) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Return a successful mock response
      return {
        "status": "success",
        "message": "User created successfully (Mock)",
        "user": {
          "id": 101,
          "name": name,
          "phone": phone,
          "user_type": type,
        }
      };
    }

    // Original code (commented out or kept as fallback)
    try {
      const String baseUrl = "https://your-python-server.com";
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
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        "status": "success",
        "message": "Ride requested successfully (Mock)",
        "ride_id": "MOCK_RIDE_123"
      };
    }

    try {
      const String baseUrl = "https://your-python-server.com";
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
