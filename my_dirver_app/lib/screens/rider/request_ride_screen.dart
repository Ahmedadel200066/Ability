import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // تم التغيير من Firebase إلى Supabase
import 'searching_driver_screen.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  String selectedVehicle = "Elite X";
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  // دالة إرسال الطلب المعدلة لتعمل مع Supabase
  Future<void> _sendRideRequest() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception("يجب تسجيل الدخول أولاً");
      }

      // 1. إرسال البيانات لجدول 'rides' في Supabase
      // ملاحظة: نستخدم insert().select().single() للحصول على بيانات الصف المضاف فوراً
      final response = await _supabase.from('rides').insert({
        'rider_id': user.id,
        'rider_name': 'إيمان سالم', // يمكنك جلب الاسم الحقيقي من البروفايل لاحقاً
        'pickup_address': 'المعادي - شارع 9',
        'destination_name': 'مطار القاهرة الدولي',
        'status': 'searching', // الحالة الابتدائية
        'price': selectedVehicle == "Elite X" ? 150.0 : 250.0,
        'vehicle_type': selectedVehicle,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      if (!mounted) return;

      // 2. الانتقال للشاشة التالية مع تمرير الـ ID الجديد من سوبابيز
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchingDriverScreen(tripId: response['id'].toString()),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ في الطلب: ${e.toString()}", style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("اطلب رحلتك",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildLocationTile(
                Icons.my_location, "المعادي - شارع 9", Colors.blue),
            const Divider(height: 30),
            _buildLocationTile(
                Icons.location_on, "مطار القاهرة الدولي", Colors.red),

            const Spacer(),

            _buildVehicleOption("Elite X", "150 جـ", Icons.directions_car),
            const SizedBox(height: 10),
            _buildVehicleOption("Elite Black", "250 جـ", Icons.business),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendRideRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1C2541),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("تأكيد وطلب Elite",
                        style: GoogleFonts.cairo(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 15),
        Text(title, style: GoogleFonts.cairo(fontSize: 16)),
      ],
    );
  }

  Widget _buildVehicleOption(String name, String price, IconData icon) {
    bool isSelected = selectedVehicle == name;
    return GestureDetector(
      onTap: () => setState(() => selectedVehicle = name),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border:
              Border.all(color: isSelected ? Colors.blue : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 20),
            Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(price,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}