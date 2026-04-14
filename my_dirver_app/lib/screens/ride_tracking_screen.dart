import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // لإجراء مكالمة حقيقية

class RideTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> rideData; // بيانات الرحلة والسائق

  const RideTrackingScreen({super.key, required this.rideData});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final _supabase = Supabase.instance.client;
  GoogleMapController? _mapController;

  // إحداثيات الراكب (ثابتة في البداية)
  late LatLng _riderLocation;
  // إحداثيات السائق (ستتحدث حياً)
  LatLng? _currentDriverLocation;

  @override
  void initState() {
    super.initState();
    _riderLocation = LatLng(widget.rideData['pickup_lat'], widget.rideData['pickup_lng']);
    _listenToDriverLocation();
  }

  // الاستماع لتحديثات موقع السائق من جدول السائقين في سوبابيز
  void _listenToDriverLocation() {
    final driverId = widget.rideData['driver_id'];

    _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', driverId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final driverData = data.first;
            setState(() {
              _currentDriverLocation = LatLng(driverData['lat'], driverData['lng']);
            });

            // تحريك الكاميرا بسلاسة لتتبع السائق
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(_currentDriverLocation!),
            );
          }
        });
  }

  // دالة الاتصال بالسائق
  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _riderLocation, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              // ماركر الراكب
              Marker(
                markerId: const MarkerId("rider"),
                position: _riderLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
              // ماركر السائق (يظهر فقط إذا توفرت الإحداثيات)
              if (_currentDriverLocation != null)
                Marker(
                  markerId: const MarkerId("driver"),
                  position: _currentDriverLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
            },
          ),

          // زر العودة بتصميم Elite
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xff1C2541)),
              ),
            ),
          ),

          Positioned(bottom: 0, left: 0, right: 0, child: _buildDriverDetailsCard()),
        ],
      ),
    );
  }

  Widget _buildDriverDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "السائق في الطريق إليك",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1C2541),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(widget.rideData['driver_image'] ?? ""),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.rideData['driver_name'] ?? "سائق إيليت",
                      style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.rideData['car_model']} | ${widget.rideData['plate_number']}",
                      style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _makePhoneCall(widget.rideData['driver_phone']),
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                  child: const Icon(Icons.call, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // إضافة منطق إلغاء الرحلة هنا
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffFEE2E2),
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 55),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("إلغاء الرحلة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}