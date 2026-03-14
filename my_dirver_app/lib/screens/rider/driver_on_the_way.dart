import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../mock/mock_firestore.dart';

class PremiumDriverOnTheWay extends StatefulWidget {
  final String tripId;
  const PremiumDriverOnTheWay({super.key, required this.tripId});

  @override
  State<PremiumDriverOnTheWay> createState() => _PremiumDriverOnTheWayState();
}

class _PremiumDriverOnTheWayState extends State<PremiumDriverOnTheWay> {
  GoogleMapController? mapController;
  final LatLng pickupLocation = const LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          var tripData = snapshot.data!.data as Map<String, dynamic>;

          LatLng driverPos = LatLng(
            tripData['driverLocation']?['lat'] ?? pickupLocation.latitude,
            tripData['driverLocation']?['lng'] ?? pickupLocation.longitude,
          );

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: pickupLocation, zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId("pickup"),
                    position: pickupLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  ),
                  Marker(
                    markerId: const MarkerId("driver"),
                    position: driverPos,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueYellow),
                  ),
                },
                onMapCreated: (controller) => mapController = controller,
              ),
              _buildDriverCard(tripData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> data) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['driverName'] ?? "Driver Name",
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data['carDetails'] ?? "Toyota Camry - ABC 123",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "4 mins",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _customButton(Icons.message, "Message", true)),
        const SizedBox(width: 12),
        Expanded(child: _customButton(Icons.call, "Call", false)),
      ],
    );
  }

  Widget _customButton(IconData icon, String text, bool isLight) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: isLight ? Colors.blue.withValues(alpha: 0.1) : Colors.blue,
      borderRadius: BorderRadius.circular(15),
      child: Icon(icon, color: isLight ? Colors.blue : Colors.white),
      onPressed: () {},
    );
  }
}
