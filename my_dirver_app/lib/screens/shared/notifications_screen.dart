import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago; // اختيارية لعرض الوقت بصيغة "منذ ساعة"

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;

  // دالة لجلب الإشعارات من سوبابيز
  Stream<List<Map<String, dynamic>>> _getNotificationsStream() {
    final userId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("الإشعارات",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text("لا توجد إشعارات حالياً",
                      style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final createdAt = DateTime.parse(notification['created_at']);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xffF0F7FF),
                  child: Icon(
                    _getIconByType(notification['type']), // دالة لاختيار الأيقونة
                    color: const Color(0xff1C2541),
                  ),
                ),
                title: Text(
                  notification['title'] ?? "تنبيه",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  notification['body'] ?? "",
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700]),
                ),
                trailing: Text(
                  timeago.format(createdAt, locale: 'ar'), // استخدام مكتبة timeago للوقت
                  style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                ),
                onTap: () {
                  // منطق عند الضغط على الإشعار (مثل الانتقال لرحلة معينة)
                },
              );
            },
          );
        },
      ),
    );
  }

  // دالة مساعدة لتغيير الأيقونة حسب نوع الإشعار
  IconData _getIconByType(String? type) {
    switch (type) {
      case 'offer': return Icons.local_offer_outlined;
      case 'trip': return Icons.directions_car_outlined;
      case 'wallet': return Icons.account_balance_wallet_outlined;
      default: return Icons.notifications_none_outlined;
    }
  }
}