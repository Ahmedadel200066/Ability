import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverRequestScreen extends StatefulWidget {
  const DriverRequestScreen({super.key});

  @override
  State<DriverRequestScreen> createState() => _DriverRequestScreenState();
}

class _DriverRequestScreenState extends State<DriverRequestScreen> {
  GoogleMapController? _mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final LatLng _driverPos = const LatLng(30.0444, 31.2357);
  final LatLng _pickupPos = const LatLng(30.0500, 31.2333);

  @override
  void initState() {
    super.initState();
    _setMapItems();
  }

  void _setMapItems() {
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_driverPos, _pickupPos],
        color: const Color(0xff007AFF),
        width: 5,
      ),
    );
  }

  // دالة تحريك الكاميرا لتشمل النقطتين معاً
  void _fitPoints() {
    if (_mapController == null) return;

    LatLngBounds bounds;
    if (_driverPos.latitude > _pickupPos.latitude) {
      bounds = LatLngBounds(southwest: _pickupPos, northeast: _driverPos);
    } else {
      bounds = LatLngBounds(southwest: _driverPos, northeast: _pickupPos);
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  String _calculateFare(double distanceInKm) {
    double fare = 15 + (distanceInKm * 8);
    return fare.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _driverPos, zoom: 14),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _fitPoints(); // استخدام المتغير هنا يحل مشكلة الـ "Unused field"
            },
            style: _mapDarkStyle,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildIncomingRequestCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xff1c1c1e).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ahmed Ali",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text("⭐ 4.9",
                      style: TextStyle(color: Color(0xff34C759), fontSize: 16)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xff34C759).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("EGP ${_calculateFare(2.5)}",
                    style: const TextStyle(
                        color: Color(0xff34C759),
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text("Pickup: Downtown Cairo",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const Divider(color: Colors.white12, height: 40),
          Row(
            children: [
              Expanded(
                  child:
                      _actionButton("Decline", const Color(0xffFF3B30), () {})),
              const SizedBox(width: 15),
              Expanded(
                  child:
                      _actionButton("Accept", const Color(0xff34C759), () {})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

const String _mapDarkStyle =
    '[]'; // اتركها فارغة مؤقتاً لتجنب أي أخطاء في الـ JSON
