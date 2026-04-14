import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ضيفي دي
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart'; // تأكدي من المسار الصح

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _userType = 'rider';

  // دالة التسجيل بعد التعديل لتعمل مع Riverpod
  void _register() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar("برجاء ملء جميع الخانات", isError: true);
      return;
    }

    // استدعاء دالة الـ signUp من البروفايدر اللي عملناها سوا
    await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
          userType: _userType,
        );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة الـ Auth
    final authState = ref.watch(authProvider);

    // الاستماع للأخطاء أو النجاح
    ref.listen<AsyncValue<Session?>>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => _showSnackBar(e.toString(), isError: true),
        data: (session) {
          if (session != null) {
            _showSnackBar("تم التسجيل بنجاح!");
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildTextField(controller: _nameController, label: "الاسم الكامل", icon: Icons.person_outline),
                  const SizedBox(height: 15),
                  _buildTextField(controller: _emailController, label: "البريد الإلكتروني", icon: Icons.email_outlined),
                  const SizedBox(height: 15),
                  _buildTextField(controller: _passwordController, label: "كلمة المرور", icon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 15),
                  _buildTextField(controller: _phoneController, label: "رقم الهاتف", icon: Icons.phone_android_outlined, isPhone: true),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                  const SizedBox(height: 30),

                  // استخدام حالة التحميل من الـ provider
                  authState.isLoading
                      ? const CircularProgressIndicator(color: Color(0xff007AFF))
                      : _buildSignupButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الـ Widgets الفرعية (_buildHeader, _buildTextField, إلخ) تبقى كما هي في كودك الأصلي
}