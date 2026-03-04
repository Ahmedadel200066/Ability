import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverSetupScreen extends StatelessWidget {
  const DriverSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إكمال بيانات السائق", style: GoogleFonts.cairo()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "يرجى رفع صور المستندات المطلوبة لتفعيل حسابك",
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildUploadCard("رخصة القيادة", Icons.badge),
            _buildUploadCard("رخصة السيارة", Icons.directions_car),
            _buildUploadCard("فيش وتشبيه", Icons.assignment_ind),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1C2541),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "إرسال للمراجعة",
                style: GoogleFonts.cairo(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 15),
              Icon(icon, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
