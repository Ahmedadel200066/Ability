import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'driver_request_screen.dart';

class OnboardingDetailsScreen extends StatefulWidget {
  const OnboardingDetailsScreen({super.key});

  @override
  State<OnboardingDetailsScreen> createState() =>
      _OnboardingDetailsScreenState();
}

class _OnboardingDetailsScreenState extends State<OnboardingDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  double _prog1 = 0.0;
  double _prog2 = 0.0;
  bool _isBtnActive = false;
  XFile? _licenseFile;
  XFile? _insuranceFile;

  void _validate() {
    setState(() {
      _isBtnActive = _nameController.text.length > 2 &&
          _phoneController.text.length >= 10 &&
          _licenseFile != null &&
          _insuranceFile != null;
    });
  }

  Future<void> _pickDocument(int type) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (photo != null) {
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() {
          if (type == 1) {
            _prog1 = i / 10;
            _licenseFile = photo;
          } else {
            _prog2 = i / 10;
            _insuranceFile = photo;
          }
        });
      }
      _validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.4),
            colors: [Color(0xff1e3c72), Color(0xff2a5298), Color(0xff0f2027)],
            radius: 1.5,
          ),
        ),
        child: Stack(
          children: [
            _buildGlowEffect(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(45),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Elite Driver\nRegistration",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildGlassInput(
                            _nameController,
                            "Full Name",
                            Icons.person,
                          ),
                          _buildGlassInput(
                            _phoneController,
                            "Phone Number",
                            Icons.phone,
                            isPhone: true,
                          ),
                          _buildUploadSection(
                            "Driver's License",
                            _licenseFile == null ? "📷" : "✅",
                            _prog1,
                            () => _pickDocument(1),
                          ),
                          _buildUploadSection(
                            "Car Insurance",
                            _insuranceFile == null ? "📄" : "✅",
                            _prog2,
                            () => _pickDocument(2),
                          ),
                          const SizedBox(height: 20),
                          const SecureBadge(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowEffect() {
    return Positioned(
      top: 100,
      left: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xff4F8CFF).withValues(alpha: 0.3),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildGlassInput(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPhone = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => _validate(),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildUploadSection(
    String title,
    String icon,
    double progress,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: const Color(0xff4F8CFF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _isBtnActive
            ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverRequestScreen(),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isBtnActive ? null : Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isBtnActive
                ? const LinearGradient(
                    colors: [Color(0xff4F8CFF), Color(0xff22C55E)],
                  )
                : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              "Submit Application",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecureBadge extends StatelessWidget {
  const SecureBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          color: Colors.white.withValues(alpha: 0.5),
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(
          "Secure & Encrypted Verification",
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    );
  }
}
