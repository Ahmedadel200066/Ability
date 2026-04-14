import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // إضافة سوبابيز

class TripCompletedScreen extends ConsumerStatefulWidget {
  final String? tripId; // استقبال رقم الرحلة
  final double? fare;   // استقبال الأجرة الحقيقية

  const TripCompletedScreen({super.key, this.tripId, this.fare});

  @override
  ConsumerState<TripCompletedScreen> createState() =>
      _TripCompletedScreenState();
}

class _TripCompletedScreenState extends ConsumerState<TripCompletedScreen> {
  int selectedRating = 0;
  final commentController = TextEditingController();
  late ConfettiController _confettiController;
  final _supabase = Supabase.instance.client;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    commentController.dispose();
    super.dispose();
  }

  // دالة إرسال التقييم لـ Supabase
  void submit() async {
    if (selectedRating == 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // تحديث التقييم والتعليق في جدول rides
      if (widget.tripId != null) {
        await _supabase.from('rides').update({
          'rating': selectedRating,
          'comment': commentController.text,
        }).eq('id', widget.tripId!);
      }

      _confettiController.play();

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // العودة للشاشة الرئيسية وحذف كل الشاشات السابقة من الـ Stack
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل حفظ التقييم: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: const GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 14),
              zoomControlsEnabled: false,
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 15),
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("إجمالي الأجرة",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(fontSize: 14)),
                    // عرض السعر الحقيقي الممرر للشاشة
                    Text("${widget.fare ?? '0.0'} جـ",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          5,
                          (index) => IconButton(
                                icon: Icon(
                                    index < selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 40,
                                    color: Colors.amber),
                                onPressed: () =>
                                    setState(() => selectedRating = index + 1),
                              )),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: commentController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                          hintText: "أضف تعليقاً عن الرحلة...",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 30),
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1C2541),
                                minimumSize: const Size(double.infinity, 60),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            child: Text("تأكيد التقييم",
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              colors: const [Colors.blue, Colors.green, Colors.orange, Colors.pink],
            ),
          ),
        ],
      ),
    );
  }
}