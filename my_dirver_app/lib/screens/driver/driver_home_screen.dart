import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // تأكد من إضافة هذا الـ Import

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isOnline = false;

  // دالة لجلب الطلبات المنتظرة من Firebase
  Stream<QuerySnapshot> _getPendingTrips() {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخريطة
          const GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 15),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
          ),

          // 2. شريط الحالة العلوي
          _buildStatusHeader(),

          // 3. الجزء المتغير (زر التفعيل أو مراقب الطلبات)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: isOnline
                ? _buildTripStreamObserver() // يراقب Firebase لو السائق Online
                : _buildGoOnlineButton(), // يعرض زر التفعيل لو السائق Offline
          ),
        ],
      ),
    );
  }

  // مراقب الطلبات: يستمع لـ Firebase ويعرض البطاقة فوراً عند وجود طلب
  Widget _buildTripStreamObserver() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPendingTrips(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          // جلب بيانات أول رحلة منتظرة
          var tripData = snapshot.data!.docs.first;
          return _buildRequestCard(tripData);
        }
        // في حال عدم وجود طلبات حالياً
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(width: 15),
              Text("بانتظار طلبات قريبة...", style: GoogleFonts.cairo()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: InkWell(
        onTap: () => setState(() => isOnline = !isOnline),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.redAccent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 5, backgroundColor: Colors.white),
              const SizedBox(width: 10),
              Text(
                isOnline
                    ? "أنت متصل الآن - جاهز للعمل"
                    : "أنت غير متصل - اضغط للبدء",
                style: GoogleFonts.cairo(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoOnlineButton() {
    return ElevatedButton(
      onPressed: () => setState(() => isOnline = true),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1C2541),
        minimumSize: const Size(double.infinity, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text("ابدأ العمل الآن",
          style: GoogleFonts.cairo(fontSize: 18, color: Colors.white)),
    );
  }

  Widget _buildRequestCard(DocumentSnapshot trip) {
    Map<String, dynamic> data = trip.data() as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("${data['price']} جـ",
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const Spacer(),
              Text("طلب من ${data['riderName']}",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          _locationRow(Icons.my_location,
              "نقطة الركوب: ${data['pickupAddress'] ?? 'موقع الراكب'}"),
          const SizedBox(height: 10),
          _locationRow(Icons.location_on,
              "الوجهة: ${data['dropoffAddress'] ?? 'وجهة الراكب'}"),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // هنا يمكن رفض الطلب محلياً
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black),
                  child: Text("تخطي", style: GoogleFonts.cairo()),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptTrip(trip.id),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff007AFF)),
                  child: Text("قبول الرحلة",
                      style: GoogleFonts.cairo(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // دالة قبول الرحلة وتحديث حالتها في Firebase
  void _acceptTrip(String tripId) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'status': 'accepted',
      'driverId': 'current_driver_id', // استبدله بـ ID السائق الحقيقي
    });

    // الانتقال لشاشة الرحلة النشطة
    if (mounted) {
      Navigator.pushNamed(context, '/active_trip');
    }
  }

  Widget _locationRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: GoogleFonts.cairo(fontSize: 14),
                textAlign: TextAlign.right)),
      ],
    );
  }
}
