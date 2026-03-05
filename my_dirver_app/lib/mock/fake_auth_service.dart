class FakeAuthService {

  Future<Map<String, dynamic>> login(String email, String password) async {

    await Future.delayed(Duration(seconds: 1));

    return {
      "id": "1",
      "name": "Test User",
      "role": "driver"
    };

  }

}