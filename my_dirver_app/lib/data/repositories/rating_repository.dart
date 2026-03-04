import 'package:dio/dio.dart';
import 'package:my_driver_app/model/rating_model.dart';

class RatingRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://api.yourapp.com",
      connectTimeout: const Duration(seconds: 5),
    ),
  );
  Future<void> submitRating(RatingModel rating) async {
    try {
      final response = await _dio.post(
        "/submit-rating",
        data: rating.toJson(),
      );
      if (response.statusCode != 200) {
        throw Exception("فشل في إرسال التقييم");
      }
    } on DioException catch (e) {
      throw Exception("خطأ في الاتصال: ${e.message}");
    }
  }
}
