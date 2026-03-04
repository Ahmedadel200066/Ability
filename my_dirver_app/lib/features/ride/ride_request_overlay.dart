import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestOverlay extends StatefulWidget {
  final String tripId; // أضفنا معرف الرحلة للوصول إليها في Firestore
  final String passengerName;
  final double rating;
  final String pickupAddress;
  final double fare;

  const RideRequestOverlay({
    super.key,
    required this.tripId,
    required this.passengerName,
    required this.rating,
    required this.pickupAddress,
    required this.fare,
  });

  @override
  State<RideRequestOverlay> createState() => _RideRequestOverlayState();
}

class _RideRequestOverlayState extends State<RideRequestOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int secondsLeft = 15;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft == 0) {
        timer.cancel();
        declineRide(); // الرفض التلقائي عند انتهاء الوقت
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // تحديث Firestore عند القبول
  Future<void> acceptRide() async {
    _timer?.cancel();
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error accepting ride: $e");
    }
  }

  // تحديث Firestore عند الرفض
  Future<void> declineRide() async {
    _timer?.cancel();
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'status': 'declined',
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error declining ride: $e");
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // تم حل التحذير باستخدام .withValues
      color: Colors.black.withValues(alpha: 0.54),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.passengerName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text("⭐ ${widget.rating}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.pickupAddress)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.green),
                  const SizedBox(width: 10),
                  Text("\$${widget.fare.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: declineRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("DECLINE"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 90 + (_pulseController.value * 15),
                              height: 90 + (_pulseController.value * 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // تم حل التحذير باستخدام .withValues
                                color: Colors.green.withValues(
                                  alpha: 0.2 * (1 - _pulseController.value),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: secondsLeft / 15,
                                strokeWidth: 6,
                                backgroundColor:
                                    Colors.green.withValues(alpha: 0.1),
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.green),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: acceptRide,
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(25),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                secondsLeft.toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
