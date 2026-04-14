import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // تم التغيير من Firebase إلى Supabase

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isOnline = false;
  final _supabase = Supabase.instance.client;

  // دالة لجلب الطلبات المنتظرة من Supabase Realtime
  Stream<List<Map<String, dynamic>>> _getPendingTrips() {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('status', 'searching'); // يراقب فقط الرحلات التي حالتها 'searching'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 15),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
          ),

          _buildStatusHeader(),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: isOnline
                ? _buildTripStreamObserver()
                : _buildGoOnlineButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStreamObserver() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getPendingTrips(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          var tripData = snapshot.data!.first;
          return _buildRequestCard(tripData);
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff007AFF)),
              ),
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
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 5, backgroundColor: Colors.white),
              const SizedBox(width: 10),
              Text(
                isOnline ? "أنت متصل - جاهز للعمل" : "أنت غير متصل - اضغط للبدء",
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildRequestCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("اجرة تقريبية", style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey)),
              const Spacer(),
              Text("طلب جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          _locationRow(Icons.my_location, "الموقع: ${data['pickup_address'] ?? 'موقع العميل'}"),
          const SizedBox(height: 10),
          _locationRow(Icons.location_on, "الوجهة: ${data['destination_name'] ?? 'وجهة غير محددة'}"),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black),
                  child: Text("تخطي", style: GoogleFonts.cairo()),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptTrip(data['id'].toString()),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff007AFF)),
                  child: Text("قبول الرحلة", style: GoogleFonts.cairo(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // دالة قبول الرحلة وتحديث حالتها في Supabase
  void _acceptTrip(String tripId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('rides').update({
        'status': 'accepted',
        'driver_id': user.id, // ID السائق الحقيقي من سوبابيز
      }).eq('id', tripId);

      if (mounted) {
        Navigator.pushNamed(context, '/active_trip');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل قبول الرحلة: $e")),
      );
    }
  }

  Widget _locationRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text, style: GoogleFonts.cairo(fontSize: 14), textAlign: TextAlign.right)),
      ],
    );
  }
}