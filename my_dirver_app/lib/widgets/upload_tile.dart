import 'package:flutter/material.dart';

class UploadTile extends StatelessWidget {
  final String title;

  const UploadTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff007AFF), width: 1.5),
        color: const Color(0xffEAF4FF),
      ),
      child: Column(
        children: [
          const Icon(Icons.camera_alt,
              size: 30, color: Color(0xff007AFF)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                color: Color(0xff007AFF),
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}