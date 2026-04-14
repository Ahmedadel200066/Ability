import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverRequestScreen extends StatefulWidget {
  final Map<String, dynamic> tripData; // استقبال بيانات الرحلة القادمة

  const DriverRequestScreen({super.key, required this.tripData});

  @override
  State<DriverRequestScreen> createState() => _DriverRequestScreenState();
}

class _DriverRequestScreenState extends State<DriverRequestScreen> {
  GoogleMapController? _mapController;
  final _supabase = Supabase.instance.client;
  bool _isProcessing = false;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // مواقع افتراضية (يفضل جلب موقع السائق الفعلي من الـ Location Service)
  final LatLng _driverPos = const LatLng(30.0444, 31.2357);
  late LatLng _pickupPos;

  @override
  void initState() {
    super.initState();
    // تحويل إحداثيات الراكب من البيانات القادمة
    _pickupPos = const LatLng(30.0500, 31.2333); // مثال، استبدليها بـ widget.tripData['lat/lng']
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

  // قبول الرحلة وتحديث الحالة في سوبابيز
  Future<void> _acceptRide() async {
    setState(() => _isProcessing = true);
    try {
      final driverId = _supabase.auth.currentUser!.id;

      await _supabase.from('rides').update({
        'status': 'accepted',
        'driver_id': driverId,
      }).eq('id', widget.tripData['id']);

      if (mounted) {
        // الانتقال لشاشة التوجه للراكب
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error accepting ride: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // رفض الرحلة (إغلاق الشاشة فقط)
  void _declineRide() {
    Navigator.pop(context);
  }

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
              _fitPoints();
            },
            zoomControlsEnabled: false,
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
        color: const Color(0xff1c1c1e).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.tripData['rider_name'] ?? "الراكب",
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const Text("⭐ 4.9",
                      style: TextStyle(color: Color(0xff34C759), fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xff34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("EGP ${widget.tripData['price']}",
                    style: const TextStyle(
                        color: Color(0xff34C759),
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text("من: ${widget.tripData['pickup_address']}",
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 40),
          _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Color(0xff34C759)))
          : Row(
            children: [
              Expanded(child: _actionButton("رفض", const Color(0xffFF3B30), _declineRide)),
              const SizedBox(width: 15),
              Expanded(child: _actionButton("قبول", const Color(0xff34C759), _acceptRide)),
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Text(label, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}