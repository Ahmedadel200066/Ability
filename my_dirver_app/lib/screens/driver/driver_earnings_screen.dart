import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      appBar: AppBar(
        title: Text("أرباحي",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1. ملخص الأرباح الأسبوعي (الرسم البياني)
            _buildWeeklySummary(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("إحصائيات اليوم",
                      style: GoogleFonts.cairo(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  /// 2. كروت الإحصائيات السريعة
                  Row(
                    children: [
                      _buildStatCard("ساعات العمل", "8.5", Icons.access_time,
                          Colors.orange),
                      const SizedBox(width: 15),
                      _buildStatCard("إجمالي الرحلات", "12",
                          Icons.directions_car, Colors.blue),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Text("آخر الرحلات",
                      style: GoogleFonts.cairo(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  /// 3. قائمة سجل الرحلات
                  _buildEarningsItem(
                      "المعادي - التجمع الخامس", "85.00 جـ", "10:30 ص"),
                  _buildEarningsItem(
                      "وسط البلد - مدينة نصر", "65.00 جـ", "08:15 ص"),
                  _buildEarningsItem("الدقي - الشيخ زايد", "110.00 جـ", "أمس"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Text("إجمالي أرباح الأسبوع",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          Text("2,450.00 جـ",
              style: GoogleFonts.poppins(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff007AFF))),
          const SizedBox(height: 20),
          // الرسم البياني
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) => _buildBar(index)),
          ),
          const SizedBox(height: 10),
          Text("من 18 فبراير - إلى 24 فبراير",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBar(int index) {
    double height = [40.0, 70.0, 50.0, 90.0, 60.0, 80.0, 100.0][index];
    return Column(
      children: [
        Container(
          height: height,
          width: 12,
          decoration: BoxDecoration(
            color: index == 6
                ? const Color(0xff007AFF)
                : const Color(0xff007AFF)
                    .withValues(alpha: 0.2), // تم التعديل هنا
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 5),
        Text(["S", "M", "T", "W", "T", "F", "S"][index],
            style:
                GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // تم التعديل هنا
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsItem(String route, String price, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text(price,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(route,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(time,
                  style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
