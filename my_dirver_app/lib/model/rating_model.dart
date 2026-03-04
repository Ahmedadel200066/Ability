class RatingModel {
  final int tripId;
  final int rating;
  final String comment;

  RatingModel({
    required this.tripId,
    required this.rating,
    required this.comment,
  });

  // تحويل البيانات من كائن (Object) إلى خريطة (Map) لإرسالها للسيرفر (JSON)
  Map<String, dynamic> toJson() {
    return {'trip_id': tripId, 'rating': rating, 'comment': comment};
  }

  // في حال أردت استقبال بيانات تقييم من السيرفر لاحقاً
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      tripId: json['trip_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}
