import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الإشعارات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xffF0F7FF), child: Icon(Icons.notifications, color: Color(0xff007AFF))),
            title: Text("خصم 20% على رحلتك القادمة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("استخدم كود ELITE20 واستمتع بخصم فوري", style: GoogleFonts.cairo(fontSize: 12)),
            trailing: Text("منذ ساعة", style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey)),
            onTap: () {},
          );
        },
      ),
    );
  }
}