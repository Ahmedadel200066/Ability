import 'package:flutter/material.dart';
import 'package:my_driver_app/presentation/widgets/upload_tile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  double _licenseProgress = 0.0;
  double _insuranceProgress = 0.0;
  String _licenseIcon = "📷";
  String _insuranceIcon = "📄";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Vehicle Details",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                buildInput("Vehicle Model", modelController),
                buildInput("Plate Number", plateController),
                buildInput(
                  "Car Year",
                  yearController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Upload Documents",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                UploadTile(
                  title: "Driver License",
                  icon: _licenseIcon,
                  progress: _licenseProgress,
                  onTap: () => _handleUpload(1),
                ),
                const SizedBox(height: 15),
                UploadTile(
                  title: "Vehicle Insurance",
                  icon: _insuranceIcon,
                  progress: _insuranceProgress,
                  onTap: () => _handleUpload(2),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff007AFF),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Submit Application",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInput(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xff007AFF)),
          ),
        ),
      ),
    );
  }
}
