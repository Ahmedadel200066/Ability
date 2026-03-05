import 'fake_database.dart';

class FakeRideService {

  void createRide(Map ride){

    FakeDatabase.createRide(ride);

  }

  List getRides(){

    return FakeDatabase.getRides();

  }

}