import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  // إحداثيات افتراضية للسائق (يتحرك باتجاه الراكب)
  final LatLng _driverLocation = const LatLng(30.0460, 31.2370);
  final LatLng _riderLocation = const LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخريطة مع تحديد المسار (بين السائق والراكب)
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _riderLocation,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("rider"),
                position: _riderLocation,
              ),
              Marker(
                markerId: const MarkerId("driver"),
                position: _driverLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ), // أيقونة السائق
              ),
            },
          ),

          // 2. زر العودة
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. كارت معلومات السائق (Driver Info Card)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildDriverDetailsCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Samer is arriving in 3 mins",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff007AFF),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  "https://via.placeholder.com/150",
                ), // صورة السائق
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Samer Mohamed",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "White Kia Cerato | ABC 123",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              // إلغاء الرحلة
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 55),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Cancel Trip",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
