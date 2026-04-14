import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart'; // إضافة سوبابيز
import 'otp_verification_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  double _progress = 0.0;
  bool _isBtnActive = false;
  bool _isLoading = false; // لمؤشر التحميل

  void _validate() {
    int filledFields = 0;
    if (_nameController.text.trim().isNotEmpty) filledFields++;
    if (_phoneController.text.trim().isNotEmpty) filledFields++;
    if (_emailController.text.trim().isNotEmpty) filledFields++;

    setState(() {
      _progress = filledFields / 3;

      bool isEmailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(_emailController.text);

      _isBtnActive = _nameController.text.length > 2 &&
          _phoneController.text.length >= 10 &&
          isEmailValid;
    });
  }

  // الدالة الأساسية لإرسال الـ OTP والتحضير للبيانات
  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();

      // 1. إرسال كود التحقق عبر سوبابيز
      await _supabase.auth.signInWithOtp(
        phone: phone,
      );

      if (mounted) {
        // ننتقل لشاشة OTP ونمرر البيانات اللي السواق كتبها عشان نحفظها بعد التحقق
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phone: phone,
              tempData: {
                'full_name': _nameController.text.trim(),
                'email': _emailController.text.trim(),
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في إرسال الكود: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
          ),
        ),
        child: Stack(
          children: [
            _buildBlob(Alignment.topLeft, const Color(0xff0A84FF)),
            _buildBlob(Alignment.bottomRight, const Color(0xff30D158)),

            Center(
              child: SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Set Up Profile",
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 35),
                          _buildGlassInput(_nameController, "Full Name", Icons.person),
                          _buildGlassInput(_phoneController, "Phone Number", Icons.phone, isPhone: true),
                          _buildGlassInput(_emailController, "Email Address", Icons.email),
                          const SizedBox(height: 10),
                          _buildPaymentTile(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 40, left: 40, right: 40,
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  // الدوال المساعدة ( _buildBlob, _buildGlassInput, _buildPaymentTile) تظل كما هي في كودك الأصلي

  Widget _buildContinueButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _isBtnActive ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isBtnActive
                ? const LinearGradient(colors: [Color(0xff0A84FF), Color(0xff30D158)])
                : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlob(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.3),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildGlassInput(TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: TextField(
        controller: controller,
        onChanged: (_) => _validate(),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          prefixIcon: Icon(icon, color: Colors.black45),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white, width: 2)),
        ),
      ),
    );
  }
}