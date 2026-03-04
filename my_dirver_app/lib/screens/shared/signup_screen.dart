import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_driver_app/presentation/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _userType = 'rider';
  bool _isLoading = false;

  void _register() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showSnackBar("برجاء ملء جميع الخانات", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    var result = await ApiService.signup(
      _nameController.text,
      _phoneController.text,
      _userType,
    );

    setState(() => _isLoading = false);

    if (result['status'] == 'success') {
      _showSnackBar("تم التسجيل بنجاح! مرحباً بك");
      // Navigator.pushNamed(context, '/home'); // يمكنك تفعيل التنقل هنا
    } else {
      _showSnackBar("خطأ: ${result['message']}", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildTextField(
                    controller: _nameController,
                    label: "الاسم الكامل",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _phoneController,
                    label: "رقم الهاتف",
                    icon: Icons.phone_android_outlined,
                    isPhone: true,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xff007AFF))
                      : _buildSignupButton(),
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
      width: double.infinity,
      height: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff007AFF), Color(0xff0057FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.drive_eta_rounded, size: 80, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            "إنشاء حساب جديد",
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xff007AFF)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        // استخدام initialValue بدلاً من value لتجنب التحذير في الإصدارات الحديثة
        initialValue: _userType,
        items: [
          DropdownMenuItem(
              value: "rider", child: Text("راكب", style: GoogleFonts.cairo())),
          DropdownMenuItem(
              value: "driver", child: Text("سائق", style: GoogleFonts.cairo())),
        ],
        onChanged: (val) {
          if (val != null) _userType = val;
        },
        decoration: const InputDecoration(border: InputBorder.none),
        icon: const Icon(Icons.arrow_drop_down_circle_outlined,
            color: Color(0xff007AFF)),
      ),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff007AFF),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: Text(
        "تسجيل الحساب",
        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
