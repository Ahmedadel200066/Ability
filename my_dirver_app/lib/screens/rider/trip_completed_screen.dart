import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

class TripCompletedScreen extends ConsumerStatefulWidget {
  const TripCompletedScreen({super.key});

  @override
  ConsumerState<TripCompletedScreen> createState() =>
      _TripCompletedScreenState();
}

class _TripCompletedScreenState extends ConsumerState<TripCompletedScreen> {
  int selectedRating = 0;
  final commentController = TextEditingController();
  late ConfettiController _confettiController;

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

  void submit() async {
    if (selectedRating == 0) return;

    _confettiController.play();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
                    Text("120.50 جـ",
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
                          hintText: "أضف تعليقاً...",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
            ),
          ),
        ],
      ),
    );
  }
}
