import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  // حالات الرحلة: 0 = في الطريق للراكب، 1 = الرحلة بدأت
  int tripStatus = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخريطة الملاحية
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(30.0444, 31.2357),
              zoom: 16,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // 2. أزرار التحكم العلوية (خروج وحماية)
          _buildTopControls(),

          // 3. لوحة التحكم السفلية (Bottom Panel)
          _buildBottomPanel(),
        ],
      ),
    );
  }

  // التحكم العلوي (زر الإغلاق وزر SOS)
  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleButton(
                Icons.close, Colors.black, () => Navigator.pop(context)),
            _circleButton(Icons.security, Colors.white, () {},
                bgColor: Colors.red),
          ],
        ),
      ),
    );
  }

  // لوحة التحكم السفلية
  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // بيانات الراكب
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
                      Text("أحمد علي",
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("التقييم: 4.8 ⭐",
                          style: GoogleFonts.cairo(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                _contactButton(Icons.chat_bubble_outline, Colors.blue),
                const SizedBox(width: 10),
                _contactButton(Icons.phone_in_talk_outlined, Colors.green),
              ],
            ),
            const Divider(height: 40),

            // تفاصيل الموقع والوقت
            _buildLocationDetail(),

            const SizedBox(height: 30),

            // زر الأكشن الرئيسي
            _buildMainButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail() {
    String title =
        tripStatus == 0 ? "الذهاب لنقطة الركوب" : "التوجه إلى الوجهة";
    String address =
        tripStatus == 0 ? "المعادي، شارع 9" : "مطار القاهرة الدولي";

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xff007AFF).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            tripStatus == 0 ? Icons.directions_car : Icons.location_on,
            color: const Color(0xff007AFF),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
              Text(address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("5 دقائق",
                style: GoogleFonts.cairo(
                    color: const Color(0xff007AFF),
                    fontWeight: FontWeight.bold)),
            Text("2.4 كم",
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    String label = tripStatus == 0 ? "وصلت لنقطة الركوب" : "إنهاء الرحلة";
    Color color = tripStatus == 0 ? const Color(0xff007AFF) : Colors.redAccent;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (tripStatus < 1) {
            tripStatus++;
          } else {
            Navigator.pop(context); // إنهاء الرحلة والعودة
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // الودجت الفرعية للأزرار الدائرية (SOS / Close)
  Widget _circleButton(IconData icon, Color color, VoidCallback onTap,
      {Color bgColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
        ],
      ),
      child: CircleAvatar(
        backgroundColor: bgColor,
        child: IconButton(onPressed: onTap, icon: Icon(icon, color: color)),
      ),
    );
  }

  // زر التواصل (Chat / Call)
  Widget _contactButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: color),
      ),
    );
  }
}
