import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io'; // نحتاجه للتعامل مع ملفات الصور
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; // افترضنا الانتقال للهوم بعد التسجيل

class OnboardingDetailsScreen extends StatefulWidget {
  const OnboardingDetailsScreen({super.key});

  @override
  State<OnboardingDetailsScreen> createState() => _OnboardingDetailsScreenState();
}

class _OnboardingDetailsScreenState extends State<OnboardingDetailsScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  double _prog1 = 0.0;
  double _prog2 = 0.0;
  bool _isLoading = false;
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

  // دالة رفع الصور لـ Supabase Storage
  Future<String?> _uploadFile(XFile file, String folder) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileExtension = file.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final path = '$folder/$fileName';

      await _supabase.storage.from('driver_docs').upload(
            path,
            File(file.path),
          );

      // الحصول على الرابط العام للملف
      return _supabase.storage.from('driver_docs').getPublicUrl(path);
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  // الدالة النهائية لحفظ الطلب
  Future<void> _submitApplication() async {
    setState(() => _isLoading = true);

    final userId = _supabase.auth.currentUser!.id;

    // 1. رفع الصور أولاً
    final licenseUrl = await _uploadFile(_licenseFile!, 'licenses');
    final insuranceUrl = await _uploadFile(_insuranceFile!, 'insurance');

    if (licenseUrl != null && insuranceUrl != null) {
      // 2. تحديث بروفايل السائق في قاعدة البيانات
      await _supabase.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'license_url': licenseUrl,
        'insurance_url': insuranceUrl,
        'status': 'pending_approval', // حالة الطلب قيد المراجعة
      }).eq('id', userId);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في رفع المستندات، حاول مرة أخرى")),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  // اختيار الصورة مع محاكاة التحميل الجمالية التي قمتِ بصنعها
  Future<void> _pickDocument(int type) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40, // تقليل الجودة قليلاً لسرعة الرفع
    );

    if (photo != null) {
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 30));
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
    // الكود الخاص بالـ UI يظل كما هو مع إضافة حالة الـ Loading في الزر
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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(45),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Elite Driver\nRegistration",
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          _buildGlassInput(_nameController, "Full Name", Icons.person),
                          _buildGlassInput(_phoneController, "Phone Number", Icons.phone, isPhone: true),
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
              bottom: 40, left: 40, right: 40,
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  // بقية الودجت الفرعية ( _buildSubmitButton, _buildGlassInput, إلخ) تظل كما هي
  // مع تغيير بسيط في الـ onPressed الخاص بـ _buildSubmitButton ليكون:
  // onPressed: _isBtnActive ? _submitApplication : null,
}