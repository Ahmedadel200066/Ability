import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  double _licenseProgress = 0.0;
  double _insuranceProgress = 0.0;
  String _licenseIcon = "📷";
  String _insuranceIcon = "📄";
  bool _isLoading = false;

  // دالة وهمية لمحاكاة الرفع (تقدري تربطيها بـ Supabase Storage زي ما عملنا في الشاشة اللي فاتت)
  void _handleUpload(int type) async {
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        if (type == 1) {
          _licenseProgress = i / 10;
          if (i == 10) _licenseIcon = "✅";
        } else {
          _insuranceProgress = i / 10;
          if (i == 10) _insuranceIcon = "✅";
        }
      });
    }
  }

  // دالة إرسال البيانات لقاعدة البيانات
  Future<void> _submitVehicleData() async {
    if (modelController.text.isEmpty || plateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("برجاء إكمال كافة البيانات")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      // تحديث بيانات المركبة في جدول البروفايل أو جدول منفصل
      await _supabase.from('profiles').update({
        'car_model': modelController.text.trim(),
        'plate_number': plateController.text.trim(),
        'car_year': int.tryParse(yearController.text.trim()),
        'onboarding_completed': true, // علامة إن السائق خلص التسجيل
      }).eq('id', userId);

      if (mounted) {
        // الانتقال لشاشة الهوم بعد النجاح
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء الحفظ: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "تفاصيل المركبة",
                  style: GoogleFonts.cairo(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1C2541),
                  ),
                ),
                const SizedBox(height: 25),
                _buildInput("موديل السيارة", modelController),
                _buildInput("رقم اللوحة", plateController),
                _buildInput(
                  "سنة التصنيع",
                  yearController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                Text(
                  "رفع المستندات",
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                // هنا استخدمت الودجت بتاعتك اللي إنتي معرفاها في الملف التاني
                _buildSimpleUploadTile(
                  "رخصة القيادة",
                  _licenseIcon,
                  _licenseProgress,
                  () => _handleUpload(1),
                ),
                const SizedBox(height: 15),
                _buildSimpleUploadTile(
                  "تأمين السيارة",
                  _insuranceIcon,
                  _insuranceProgress,
                  () => _handleUpload(2),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1C2541),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _submitVehicleData,
                        child: Text(
                          "إتمام التسجيل",
                          style: GoogleFonts.cairo(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xff1C2541), width: 2),
          ),
        ),
      ),
    );
  }

  // ودجت تجريبية للرفع لو الـ UploadTile مش متعرفة في نفس الملف
  Widget _buildSimpleUploadTile(String title, String icon, double progress, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}