import 'package:flutter/material.dart';

class UploadTile extends StatelessWidget {
  final String title;
  final String icon;
  final double progress;
  final VoidCallback onTap;

  const UploadTile({
    super.key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: const Color(0xff4F8CFF),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}
