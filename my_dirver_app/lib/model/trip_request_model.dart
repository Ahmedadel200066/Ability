class TripRequest {
  final String id;
  final String riderName;
  final String riderId;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String status; // (pending, accepted, ongoing, completed)
  final double price;

  TripRequest({
    required this.id,
    required this.riderName,
    required this.riderId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.status = 'pending',
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'riderName': riderName,
      'riderId': riderId,
      'pickup': {'lat': pickupLat, 'lng': pickupLng},
      'dropoff': {'lat': dropoffLat, 'lng': dropoffLng},
      'status': status,
      'price': price,
      'createdAt': DateTime.now(),
    };
  }
}
