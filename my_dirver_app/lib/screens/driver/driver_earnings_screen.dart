import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  final _supabase = Supabase.instance.client;

  // دالة لجلب إجمالي الأرباح الحقيقية من Supabase
  Future<Map<String, dynamic>> _getEarningsData() async {
    final userId = _supabase.auth.currentUser!.id;

    // جلب الرحلات المكتملة للسائق الحالي
    final response = await _supabase
        .from('rides')
        .select('price')
        .eq('driver_id', userId)
        .eq('status', 'completed');

    double totalEarnings = 0;
    for (var record in response) {
      totalEarnings += (record['price'] ?? 0).toDouble();
    }

    return {
      'total': totalEarnings,
      'count': response.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      appBar: AppBar(
        title: Text("أرباحي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getEarningsData(),
        builder: (context, snapshot) {
          // بيانات افتراضية في حالة التحميل أو عدم وجود بيانات
          double displayTotal = snapshot.data?['total'] ?? 0.0;
          int rideCount = snapshot.data?['count'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                /// 1. ملخص الأرباح الأسبوعي
                _buildWeeklySummary(displayTotal),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("إحصائيات العمل",
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      /// 2. كروت الإحصائيات
                      Row(
                        children: [
                          _buildStatCard("ساعات النشاط", "---", Icons.access_time, Colors.orange),
                          const SizedBox(width: 15),
                          _buildStatCard("رحلات مكتملة", rideCount.toString(), Icons.directions_car, Colors.blue),
                        ],
                      ),

                      const SizedBox(height: 25),
                      Text("آخر العمليات",
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      /// 3. قائمة سجل الرحلات (يمكنك مستقبلاً عمل Stream لهذه القائمة)
                      _buildEarningsItem("المعادي - التجمع الخامس", "85.00 جـ", "اليوم"),
                      _buildEarningsItem("وسط البلد - مدينة نصر", "65.00 جـ", "اليوم"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklySummary(double total) {
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
          Text("إجمالي الأرباح الحالية",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          Text("${total.toStringAsFixed(2)} جـ",
              style: GoogleFonts.poppins(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff007AFF))),
          const SizedBox(height: 20),
          // الرسم البياني (يمكنك ربطه لاحقاً ببيانات يومية حقيقية)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) => _buildBar(index)),
          ),
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
            color: index == 6 ? const Color(0xff007AFF) : const Color(0xff007AFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 5),
        Text(["S", "M", "T", "W", "T", "F", "S"][index],
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsItem(String route, String price, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text(price, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(route, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(time, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}