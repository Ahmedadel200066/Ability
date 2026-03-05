class FakeDatabase {

  static List rides = [
    {
      'id': 'sample_trip_1',
      'riderName': 'Sample Rider',
      'pickupAddress': 'Sample Pickup',
      'dropoffAddress': 'Sample Dropoff',
      'status': 'pending',
      'price': 100.0,
      'vehicleType': 'Elite X',
      'createdAt': DateTime.now(),
    }
  ];

  static createRide(Map ride){

    rides.add(ride);

  }

  static updateRide(String id, Map updates){
    int index = rides.indexWhere((ride) => ride['id'] == id);
    if (index != -1) {
      rides[index] = {...rides[index], ...updates};
    }
  }

  static List getRides(){

    return rides;

  }

}