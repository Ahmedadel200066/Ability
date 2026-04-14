import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // تم التغيير من Firebase إلى Supabase

class PremiumDriverOnTheWay extends StatefulWidget {
  final String tripId;
  const PremiumDriverOnTheWay({super.key, required this.tripId});

  @override
  State<PremiumDriverOnTheWay> createState() => _PremiumDriverOnTheWayState();
}

class _PremiumDriverOnTheWayState extends State<PremiumDriverOnTheWay> {
  GoogleMapController? mapController;
  final _supabase = Supabase.instance.client;

  // موقع افتراضي للركوب (يمكنك جلبه لاحقاً من بيانات الرحلة)
  final LatLng pickupLocation = const LatLng(30.0444, 31.2357);

  // دالة لجلب تيار بيانات الرحلة (Realtime) من سوبابيز
  Stream<List<Map<String, dynamic>>> _getTripStream() {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getTripStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("جاري تحميل بيانات الرحلة..."));
          }

          var tripData = snapshot.data!.first;

          // جلب موقع السائق من قاعدة البيانات
          // تأكدي من وجود أعمدة driver_lat و driver_lng في جدول rides
          LatLng driverPos = LatLng(
            (tripData['driver_lat'] ?? pickupLocation.latitude).toDouble(),
            (tripData['driver_lng'] ?? pickupLocation.longitude).toDouble(),
          );

          // تحريك الكاميرا تلقائياً لتتبع السائق والراكب معاً
          _updateCameraBounds(driverPos);

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: pickupLocation, zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId("pickup"),
                    position: pickupLocation,
                    infoWindow: const InfoWindow(title: "موقع الركوب"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  ),
                  Marker(
                    markerId: const MarkerId("driver"),
                    position: driverPos,
                    infoWindow: const InfoWindow(title: "السائق"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                  ),
                },
                onMapCreated: (controller) => mapController = controller,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
              _buildDriverCard(tripData),

              // زر العودة
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
            ],
          );
        },
      ),
    );
  }

  // دالة لتعديل زاوية الرؤية لتشمل السائق والراكب
  void _updateCameraBounds(LatLng driverPos) {
    if (mapController == null) return;

    LatLngBounds bounds;
    if (pickupLocation.latitude > driverPos.latitude) {
      bounds = LatLngBounds(southwest: driverPos, northeast: pickupLocation);
    } else {
      bounds = LatLngBounds(southwest: pickupLocation, northeast: driverPos);
    }

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xffF0F7FF),
                  child: Icon(Icons.person, color: Color(0xff007AFF), size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['driver_name'] ?? "جاري البحث...",
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data['car_model'] ?? "تويوتا كورولا - أ ب ج ١٢٣",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Column(
                  children: [
                    Text(
                      "4",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Text("دقائق", style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
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
        Expanded(child: _customButton(Icons.message, "رسالة", true)),
        const SizedBox(width: 12),
        Expanded(child: _customButton(Icons.call, "اتصال", false)),
      ],
    );
  }

  Widget _customButton(IconData icon, String text, bool isLight) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: isLight ? Colors.blue.withOpacity(0.1) : Colors.blue,
      borderRadius: BorderRadius.circular(15),
      onPressed: () {
        // منطق الاتصال أو المراسلة
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isLight ? Colors.blue : Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isLight ? Colors.blue : Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}