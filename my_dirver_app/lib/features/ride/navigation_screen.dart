import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من إضافة الاعتماد في pubspec.yaml

class NavigationScreen extends StatefulWidget {
  final String tripId;
  final String passengerPhone; // أضفنا رقم الهاتف كمعامل

  const NavigationScreen({
    super.key,
    required this.tripId,
    required this.passengerPhone,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late GoogleMapController mapController;

  final LatLng driverLocation = const LatLng(30.0444, 31.2357);
  final LatLng pickupLocation = const LatLng(30.0500, 31.2400);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }

  void _setupMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [driverLocation, pickupLocation],
        color: Colors.blue,
        width: 6,
      ),
    );
  }

  // 1. تحديث Firebase عند الوصول
  Future<void> onArrived() async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'status': 'arrived',
        'arrivalTime': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إخطار الراكب بوصولك ✅")),
        );
      }
    } catch (e) {
      debugPrint("خطأ في تحديث الحالة: $e");
    }
  }

  // 2. تشغيل مكالمة هاتفية للراكب
  Future<void> contactPassenger() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: widget.passengerPhone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر إجراء المكالمة حالياً")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: driverLocation, zoom: 14),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    // حل تحذير withOpacity
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xffF0F7FF),
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "أحمد حسن",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: contactPassenger,
                        icon: const Icon(Icons.phone,
                            size: 18, color: Colors.white),
                        label: const Text("اتصال",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onArrived,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        "لقد وصلت لنقطة الركوب",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
