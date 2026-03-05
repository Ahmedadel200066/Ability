import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../mock/mock_firestore.dart';
import '../mock/mock_auth.dart';
import '../features/ride/ride_request_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = false;
  double todayEarnings = 320.75;
  int totalTrips = 18;

  // معرف السائق الحالي من Firebase Auth
  final String? driverId = FirebaseAuth.instance.currentUser?.uid;

  late GoogleMapController mapController;

  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(30.0444, 31.2357),
    zoom: 14,
  );

  // تحديث حالة السائق
  void toggleStatus(bool value) async {
    if (driverId == null) return;

    setState(() {
      isOnline = value;
    });

    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({
        'isOnline': value,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      _showSnackBar(value
          ? "أنت الآن متصل وتستقبل الطلبات"
          : "تم تسجيل الخروج من الخدمة");
    } catch (e) {
      // إذا لم يكن المستند موجوداً، ننشئه
      await FirebaseFirestore.instance.collection('drivers').doc(driverId).set({
        'isOnline': value,
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isOnline ? Colors.green : Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showRideRequest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RideRequestOverlay(
        tripId: "REQ_ID_2026", // تمرير الـ ID المطلوب لحل خطأ الـ Required
        passengerName: "أحمد حسن",
        rating: 4.9,
        pickupAddress: "مدينة نصر، القاهرة",
        fare: 75.50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخريطة
          GoogleMap(
            initialCameraPosition: initialPosition,
            onMapCreated: (controller) => mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // الجزء العلوي (Status Toggle)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: (isOnline ? Colors.green : Colors.red)
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOnline ? "أنت متصل الآن" : "أنت غير متصل",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // حل مشكلة activeColor الـ Deprecated هنا
                    Switch(
                      value: isOnline,
                      onChanged: toggleStatus,
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.white.withValues(alpha: 0.4),
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: Colors.black.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // شريط الأرباح السفلي
          _buildEarningsBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showRideRequest,
        backgroundColor: const Color(0xff1C2541),
        child: const Icon(Icons.notifications, color: Colors.white),
      ),
    );
  }

  Widget _buildEarningsBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _earningColumn(
                "أرباح اليوم", "EGP ${todayEarnings.toStringAsFixed(2)}"),
            Container(
                height: 40,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.3)),
            _earningColumn("إجمالي الرحلات", totalTrips.toString(),
                isEnd: true),
          ],
        ),
      ),
    );
  }

  Widget _earningColumn(String label, String value, {bool isEnd = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
