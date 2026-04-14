import 'package:flutter/material.dart';

class UploadTile extends StatelessWidget {
  final String title;
  final String icon; // لتغيير الإيموجي أو الأيقونة (مثل ✅ أو 📷)
  final double progress; // لعرض شريط التحميل
  final VoidCallback onTap; // الوظيفة اللي هتتنفذ عند الضغط

  const UploadTile({
    super.key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: progress == 1.0 ? Colors.green : const Color(0xff007AFF).withOpacity(0.3),
            width: 1.5,
          ),
          color: progress == 1.0 ? Colors.green.withOpacity(0.05) : const Color(0xffF8FBFF),
        ),
        child: Column(
          children: [
            // أيقونة الحالة (📷 أو ✅)
            Text(
              icon,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff1C2541),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 15),
            // شريط التحميل (بيظهر التقدم الحقيقي)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: progress == 1.0 ? Colors.green : const Color(0xff007AFF),
                minHeight: 6,
              ),
            ),
            if (progress == 1.0)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "تم الرفع بنجاح",
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}