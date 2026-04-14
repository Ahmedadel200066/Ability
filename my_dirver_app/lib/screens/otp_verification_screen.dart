import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_details_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone; // نمرر رقم الهاتف للشاشة

  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  Timer? _timer;
  int _start = 30;
  bool _canResend = false;
  bool _isLoading = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  // دالة التحقق من الكود في سوبابيز
  Future<void> _verifyOtp() async {
    String otpCode = _controllers.map((controller) => controller.text).join();

    if (otpCode.length < 6) {
      _showSnackBar("برجاء إدخال الكود كاملاً");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _supabase.auth.verifyOTP(
        phone: widget.phone,
        token: otpCode,
        type: OtpType.sms,
      );

      if (response.session != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingDetailsScreen(),
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar("الكود غير صحيح أو انتهت صلاحيته");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // إعادة إرسال الكود
  Future<void> _resendCode() async {
    try {
      await _supabase.auth.signInWithOtp(phone: widget.phone);
      _startTimer();
      _showSnackBar("تم إعادة إرسال الكود");
    } catch (e) {
      _showSnackBar("حدث خطأ أثناء إعادة الإرسال");
    }
  }

  void _startTimer() {
    setState(() { _start = 30; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() { timer.cancel(); _canResend = true; });
      } else {
        setState(() { _start--; });
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.cairo())),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    for (var node in _focusNodes) node.dispose();
    for (var controller in _controllers) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "التحقق من رقم الهاتف",
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1C2541),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "أدخل الكود المرسل إلى ${widget.phone}",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xff8E8E93)),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _canResend ? _resendCode : null,
                    child: Text(
                      "إعادة إرسال الكود",
                      style: GoogleFonts.cairo(
                        color: _canResend ? const Color(0xff007AFF) : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "00:${_start.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Color(0xff8E8E93)),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _isLoading
              ? const CircularProgressIndicator()
              : ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.05).animate(_pulseController),
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1C2541), // توحيد اللون الكحلي لـ Elite
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "تحقق الآن",
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffD1D1D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: const Color(0xff1C2541), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}