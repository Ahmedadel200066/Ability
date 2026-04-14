import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ride_request_overlay.dart'; // تأكدي من المسار الصحيح

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  bool isOnline = false;
  double todayEarnings = 0.0;
  int totalTrips = 0;

  late GoogleMapController mapController;

  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(30.0444, 31.2357),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
    _listenToNewRequests(); // بدء الاستماع للطلبات الجديدة
  }

  // جلب بيانات السائق (الأرباح والرحلات) من Supabase
  Future<void> _fetchDriverData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase
        .from('profiles')
        .select('wallet_balance, total_trips, is_online')
        .eq('id', user.id)
        .single();

    setState(() {
      todayEarnings = (data['wallet_balance'] ?? 0).toDouble();
      totalTrips = data['total_trips'] ?? 0;
      isOnline = data['is_online'] ?? false;
    });
  }

  // الاستماع لطلبات الرحلات الجديدة (Real-time)
  void _listenToNewRequests() {
    _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('status', 'searching') // استماع للرحلات اللي بتبحث عن سائق
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty && isOnline) {
            _showRideRequestPopup(data.last);
          }
        });
  }

  // تحديث حالة الاتصال في الداتابيز
  void toggleStatus(bool value) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => isOnline = value);

    try {
      await _supabase.from('profiles').update({
        'is_online': value,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      _showSnackBar(value ? "أنت الآن متصل وتستقبل الطلبات" : "تم تسجيل الخروج من الخدمة");
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  void _showRideRequestPopup(Map<String, dynamic> ride) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RideRequestOverlay(
        tripId: ride['id'].toString(),
        passengerName: ride['rider_name'] ?? "عميل",
        rating: 4.8,
        pickupAddress: ride['pickup_address'] ?? "موقع العميل",
        fare: (ride['price'] ?? 0).toDouble(),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: isOnline ? Colors.green : Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            onMapCreated: (controller) => mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // الـ Header (الحالة)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xff1C2541) : Colors.redAccent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOnline ? "أنت متصل الآن" : "أنت غير متصل",
                      style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isOnline,
                      onChanged: toggleStatus,
                      activeColor: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),

          _buildEarningsBar(),
        ],
      ),
    );
  }

  Widget _buildEarningsBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _earningColumn("أرباح اليوم", "EGP ${todayEarnings.toStringAsFixed(2)}"),
            _earningColumn("إجمالي الرحلات", totalTrips.toString(), isEnd: true),
          ],
        ),
      ),
    );
  }

  Widget _earningColumn(String label, String value, {bool isEnd = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}