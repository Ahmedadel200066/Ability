import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  // دالة لجلب بيانات المستخدم من جدول Profiles
  Future<Map<String, dynamic>> _getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return data;
  }

  // دالة تسجيل الخروج
  Future<void> _handleLogout() async {
    await _supabase.auth.signOut();
    if (mounted) {
      // العودة لصفحة تسجيل الدخول
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(profile),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildSectionTitle("حسابي"),
                      _buildSettingsCard([
                        _buildSettingsTile(Icons.person_outline, "تعديل الملف الشخصي", () {}),
                        _buildSettingsTile(Icons.account_balance_wallet_outlined, "طرق الدفع", () {}),
                        _buildSettingsTile(Icons.history, "سجل الرحلات", () {}),
                      ]),
                      const SizedBox(height: 25),
                      _buildSectionTitle("الإعدادات"),
                      _buildSettingsCard([
                        _buildSettingsTile(Icons.notifications_none, "التنبيهات", () {}),
                        _buildSettingsTile(Icons.language, "اللغة", () {}, trailing: "العربية"),
                        _buildSettingsTile(Icons.dark_mode_outlined, "الوضع الليلي", () {}),
                      ]),
                      const SizedBox(height: 25),
                      _buildSectionTitle("الدعم"),
                      _buildSettingsCard([
                        _buildSettingsTile(Icons.help_outline, "مركز المساعدة", () {}),
                        _buildSettingsTile(Icons.info_outline, "عن التطبيق", () {}),
                      ]),
                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic>? profile) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xff1C2541), // توحيد الهوية مع التطبيق
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1C2541), Color(0xff3A506B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                // عرض صورة المستخدم لو موجودة أو أيقونة افتراضية
                backgroundImage: profile?['avatar_url'] != null
                    ? NetworkImage(profile!['avatar_url'])
                    : null,
                child: profile?['avatar_url'] == null
                    ? const Icon(Icons.person, size: 60, color: Color(0xff1C2541))
                    : null,
              ),
              const SizedBox(height: 15),
              Text(
                profile?['full_name'] ?? "جاري التحميل...",
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    profile?['rating']?.toString() ?? "5.0",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {String? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (trailing != null) Text(trailing, style: GoogleFonts.cairo(color: Colors.blue, fontSize: 14)),
          if (trailing != null) const SizedBox(width: 10),
          Text(title, style: GoogleFonts.cairo(fontSize: 15)),
          const SizedBox(width: 15),
          Icon(icon, color: const Color(0xff1C2541), size: 22),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _handleLogout,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text("تسجيل الخروج", style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}