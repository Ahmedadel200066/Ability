import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // ستحتاجين إضافة حزمة intl لتنسيق التاريخ

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final _supabase = Supabase.instance.client;

  // دالة لجلب الرحلات من جدول rides
  Stream<List<Map<String, dynamic>>> _getRidesHistory() {
    final userId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('rider_id', userId) // جلب الرحلات الخاصة بهذا الراكب فقط
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      appBar: AppBar(
        title: Text("رحلاتي السابقة",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getRidesHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("لا توجد رحلات سابقة حتى الآن",
                  style: GoogleFonts.cairo(color: Colors.grey)),
            );
          }

          final rides = snapshot.data!;

          return ListView.builder(
            itemCount: rides.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final ride = rides[index];

              // تنسيق تاريخ الرحلة
              final DateTime createdAt = DateTime.parse(ride['created_at']);
              final String formattedDate = DateFormat('dd MMMM, yyyy', 'ar').format(createdAt);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formattedDate,
                            style: GoogleFonts.cairo(
                                color: Colors.grey, fontSize: 12)),
                        _buildStatusBadge(ride['status']),
                      ],
                    ),
                    const Divider(height: 25),
                    _locationRow(Icons.circle, ride['pickup_address'] ?? "غير معروف", Colors.blue),
                    const SizedBox(height: 10),
                    _locationRow(Icons.location_on, ride['destination_name'] ?? "غير معروف", Colors.red),
                    const Divider(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${ride['price']} جـ",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        ElevatedButton(
                          onPressed: () {
                            // هنا يمكنك الانتقال لشاشة تفاصيل الرحلة لاحقاً
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffF0F7FF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text("تفاصيل",
                              style: GoogleFonts.cairo(color: Colors.blue)),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // دالة لتلوين حالة الرحلة
  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'completed':
        color = Colors.green;
        text = "تمت بنجاح";
        break;
      case 'cancelled':
        color = Colors.red;
        text = "ملغاة";
        break;
      default:
        color = Colors.orange;
        text = "قيد التنفيذ";
    }

    return Text(text,
        style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold));
  }

  Widget _locationRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right, // ليتناسب مع اللغة العربية
          ),
        ),
      ],
    );
  }
}