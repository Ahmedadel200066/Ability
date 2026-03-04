import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_details_screen.dart'; // تأكد من مطابقة اسم الملف في مشروعك

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  // التحكم في مربعات الـ OTP
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // مؤقت العد التنازلي
  Timer? _timer;
  int _start = 30;
  bool _canResend = false;

  // تأثير النبض (Pulse Animation) للزر
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

  void _startTimer() {
    setState(() {
      _start = 30;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
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
              const Text(
                "Verify Phone Number",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1C2541),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter the code sent to your phone",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xff8E8E93)),
              ),
              const SizedBox(height: 32),

              // مربعات الـ OTP (6 مربعات)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),

              const SizedBox(height: 24),

              // الروابط والعد التنازلي
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _canResend ? _startTimer : null,
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                        color:
                            _canResend ? const Color(0xff007AFF) : Colors.grey,
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

              // زر التحقق مع تأثير النبض
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.05).animate(_pulseController),
                child: ElevatedButton(
                  onPressed: () {
                    // الانتقال لشاشة تسجيل البيانات (Elite Onboarding)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingDetailsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff007AFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    // تم استبدال withOpacity بـ withValues لتجنب التحذير
                    shadowColor: const Color(0xff007AFF).withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
      height: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffD1D1D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff007AFF), width: 2),
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
