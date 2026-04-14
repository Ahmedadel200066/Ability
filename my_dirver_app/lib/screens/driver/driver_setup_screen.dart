import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverSetupScreen extends StatefulWidget {
  const DriverSetupScreen({super.key});

  @override
  State<DriverSetupScreen> createState() => _DriverSetupScreenState();
}

class _DriverSetupScreenState extends State<DriverSetupScreen> {
  final _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // تخزين مسارات الصور المختارة لعرضها أو رفعها
  Map<String, File?> _files = {
    "license": null,
    "car_reg": null,
    "criminal_record": null,
  };

  bool _isUploading = false;

  // دالة اختيار الصورة
  Future<void> _pickImage(String key) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _files[key] = File(image.path);
      });
    }
  }

  // دالة رفع الملفات إلى Supabase Storage
  Future<void> _submitData() async {
    if (_files.values.any((file) => file == null)) {
      _showSnackBar("يرجى رفع جميع المستندات المطلوبة", isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      for (var entry in _files.entries) {
        final file = entry.value!;
        final fileExt = file.path.split('.').last;
        final fileName = '${entry.key}_$userId.$fileExt';
        final filePath = 'drivers_docs/$userId/$fileName';

        // الرفع إلى Bucket يسمى 'documents' (يجب إنشاؤه في لوحة تحكم سوبابيز)
        await _supabase.storage.from('documents').upload(
              filePath,
              file,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );
      }

      _showSnackBar("تم إرسال المستندات بنجاح للمراجعة");
      if (mounted) Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      _showSnackBar("حدث خطأ أثناء الرفع: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إكمال بيانات السائق", style: GoogleFonts.cairo()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "يرجى رفع صور المستندات المطلوبة لتفعيل حسابك",
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildUploadCard("رخصة القيادة", Icons.badge, "license"),
            _buildUploadCard("رخصة السيارة", Icons.directions_car, "car_reg"),
            _buildUploadCard("فيش وتشبيه", Icons.assignment_ind, "criminal_record"),
            const Spacer(),
            _isUploading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1C2541),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "إرسال للمراجعة",
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(String title, IconData icon, String key) {
    bool hasFile = _files[key] != null;

    return GestureDetector(
      onTap: () => _pickImage(key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: hasFile ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: hasFile ? Colors.green : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
              color: hasFile ? Colors.green : Colors.blue,
            ),
            Row(
              children: [
                Text(
                  hasFile ? "تم اختيار الملف" : title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: hasFile ? Colors.green : Colors.black,
                  ),
                ),
                const SizedBox(width: 15),
                Icon(icon, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}