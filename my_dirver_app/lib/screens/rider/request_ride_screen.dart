import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ملاحظة: تأكد أن ملف searching_driver_screen.dart موجود في نفس المجلد
import 'searching_driver_screen.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  String selectedVehicle = "Elite X";
  bool _isLoading = false;

  // دالة إرسال الطلب
  Future<void> _sendRideRequest() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 1. إرسال البيانات لـ Firestore
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('trips').add({
        'riderName': 'رامي محمد',
        'riderId': 'rider_123',
        'pickupAddress': 'المعادي - شارع 9',
        'dropoffAddress': 'مطار القاهرة الدولي',
        'status': 'pending',
        'price': selectedVehicle == "Elite X" ? 150.0 : 250.0,
        'vehicleType': selectedVehicle,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. حماية الـ BuildContext (Async Gap)
      if (!mounted) return;

      // 3. الانتقال للشاشة التالية
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchingDriverScreen(tripId: docRef.id),
        ),
      );
    } catch (e) {
      // حماية الـ BuildContext عند الخطأ
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ: ${e.toString()}", style: GoogleFonts.cairo()),
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
            // عرض العناوين بشكل مبسط
            _buildLocationTile(
                Icons.my_location, "المعادي - شارع 9", Colors.blue),
            const Divider(height: 30),
            _buildLocationTile(
                Icons.location_on, "مطار القاهرة الدولي", Colors.red),

            const Spacer(),

            // اختيار نوع السيارة
            _buildVehicleOption("Elite X", "150 جـ", Icons.directions_car),
            const SizedBox(height: 10),
            _buildVehicleOption("Elite Black", "250 جـ", Icons.business),

            const SizedBox(height: 30),

            // زر التأكيد
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
              ? Colors.blue.withValues(alpha: 0.1)
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
