import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // إضافة سوبابيز

class ActiveTripScreen extends StatefulWidget {
  // يفضل تمرير معرف الرحلة هنا لكي نعرف أي رحلة نحدث بياناتها
  final String? tripId;
  const ActiveTripScreen({super.key, this.tripId});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final _supabase = Supabase.instance.client;

  // حالات الرحلة: 0 = في الطريق، 1 = تم الوصول، 2 = بدأت الرحلة
  int tripStatus = 0;
  bool _isLoading = false;

  // دالة لتحديث حالة الرحلة في قاعدة البيانات
  Future<void> _updateTripStatus(String newStatus) async {
    if (widget.tripId == null) return;

    setState(() => _isLoading = true);
    try {
      await _supabase
          .from('rides')
          .update({'status': newStatus})
          .eq('id', widget.tripId!);

      if (newStatus == 'completed') {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في تحديث الحالة: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(30.0444, 31.2357),
              zoom: 16,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          _buildTopControls(),

          _buildBottomPanel(),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleButton(Icons.close, Colors.black, () => Navigator.pop(context)),
            _circleButton(Icons.security, Colors.white, () {}, bgColor: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xffF0F7FF),
                  child: Icon(Icons.person, color: Color(0xff007AFF)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("أحمد علي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("التقييم: 4.8 ⭐", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                _contactButton(Icons.chat_bubble_outline, Colors.blue),
                const SizedBox(width: 10),
                _contactButton(Icons.phone_in_talk_outlined, Colors.green),
              ],
            ),
            const Divider(height: 40),
            _buildLocationDetail(),
            const SizedBox(height: 30),
            _buildMainButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail() {
    String title = tripStatus == 0 ? "الذهاب لنقطة الركوب" : "التوجه إلى الوجهة";
    String address = tripStatus == 0 ? "المعادي، شارع 9" : "مطار القاهرة الدولي";

    return Row(
      children: [
        Icon(tripStatus == 0 ? Icons.directions_car : Icons.location_on, color: const Color(0xff007AFF)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
              Text(address, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    String label;
    if (tripStatus == 0) {
      label = "وصلت لنقطة الركوب";
    } else if (tripStatus == 1) {
      label = "بدء الرحلة الآن";
    } else {
      label = "إنهاء الرحلة";
    }

    Color color = tripStatus < 2 ? const Color(0xff007AFF) : Colors.redAccent;

    return ElevatedButton(
      onPressed: () {
        if (tripStatus == 0) {
          _updateTripStatus('arrived'); // تحديث في سوبابيز
          setState(() => tripStatus = 1);
        } else if (tripStatus == 1) {
          _updateTripStatus('on_trip'); // تحديث في سوبابيز
          setState(() => tripStatus = 2);
        } else {
          _updateTripStatus('completed'); // إنهاء الرحلة
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(label, style: GoogleFonts.cairo(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap, {Color bgColor = Colors.white}) {
    return CircleAvatar(
      backgroundColor: bgColor,
      child: IconButton(onPressed: onTap, icon: Icon(icon, color: color)),
    );
  }

  Widget _contactButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: IconButton(onPressed: () {}, icon: Icon(icon, color: color)),
    );
  }
}