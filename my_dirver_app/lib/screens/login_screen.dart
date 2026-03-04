import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة الدخول
    final authState = ref.watch(authProvider);

    // الاستماع للتغييرات (إظهار خطأ أو انتقال لشاشة أخرى)
    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        ),
        data: (token) {
          if (token != null) Navigator.pushReplacementNamed(context, '/home');
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "تسجيل الدخول",
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "أهلاً بك مجدداً في تطبيق إيليت",
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  _buildTextField(
                    phoneController,
                    "رقم الهاتف",
                    Icons.phone_android_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    passwordController,
                    "كلمة المرور",
                    Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 15),
                  Text(
                    "نسيت كلمة المرور؟",
                    style: GoogleFonts.cairo(
                      color: const Color(0xff007AFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildLoginButton(authState.isLoading),

                  const SizedBox(height: 30),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: "ليس لديك حساب؟ "),
                          TextSpan(
                            text: "سجل الآن",
                            style: GoogleFonts.cairo(
                              color: const Color(0xff007AFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff007AFF), Color(0xff0057FF)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      child: const Center(
        child: Icon(Icons.directions_car_filled, size: 80, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff007AFF)),
        labelStyle: GoogleFonts.cairo(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              ref
                  .read(authProvider.notifier)
                  .login(phoneController.text, passwordController.text);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff007AFF),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              "دخول",
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
