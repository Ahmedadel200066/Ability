import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'premium_driver_on_the_way.dart'; // تأكدي من استيراد شاشة التتبع

class SearchingDriverScreen extends StatefulWidget {
  final String tripId;

  const SearchingDriverScreen({super.key, required this.tripId});

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _listenToTripStatus();
  }

  // دالة لمراقبة حالة الرحلة لحظة بلحظة
  void _listenToTripStatus() {
    _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', widget.tripId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final status = data.first['status'];

            // أول ما الحالة تتغير من searching لـ accepted
            if (status == 'accepted') {
              if (mounted) {
                // ننتقل لشاشة تتبع السائق ونبعت الـ tripId
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PremiumDriverOnTheWay(tripId: widget.tripId),
                  ),
                );
              }
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أنيميشن بسيط أو دايرة تحميل شكلها شيك
            const SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xff007AFF),
                  ),
                  Icon(Icons.directions_car, size: 50, color: Color(0xff007AFF)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "جاري البحث عن كابتن...",
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "طلبك رقم #${widget.tripId} قيد المراجعة الآن",
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            // زر لإلغاء الطلب لو الراكب غير رأيه
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "إلغاء الطلب",
                style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}