import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("رحلاتي السابقة",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.all(15),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("26 فبراير، 2026",
                        style: GoogleFonts.cairo(
                            color: Colors.grey, fontSize: 12)),
                    Text("تمت بنجاح",
                        style: GoogleFonts.cairo(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 25),
                _locationRow(Icons.circle, "المعادي، القاهرة", Colors.blue),
                const SizedBox(height: 10),
                _locationRow(
                    Icons.location_on, "مطار القاهرة الدولي", Colors.red),
                const Divider(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("150.00 جـ",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    ElevatedButton(
                      onPressed: () {},
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
      ),
    );
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
          ),
        ),
      ],
    );
  }
}
