import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // استيراد سوبابيز
import '../ride_tracking_screen.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(30.0444, 31.2357);
  int _selectedCard = 0;
  bool _isDestinationSelected = false;
  String _destinationText = "Where to?";
  bool _isSearching = false;

  // الوصول لعميل سوبابيز
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );
    } catch (e) {
      debugPrint("خطأ في تحديد الموقع: $e");
    }
  }

  // --- دالة إرسال الطلب المعدلة لتعمل مع Supabase ---
  void _sendRideRequest() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب تسجيل الدخول أولاً")),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // إرسال طلب الرحلة لجدول يسمى 'rides' في سوبابيز
      await _supabase.from('rides').insert({
        'rider_id': user.id, // معرف المستخدم الحقيقي
        'pickup_lat': _currentPosition.latitude,
        'pickup_lng': _currentPosition.longitude,
        'destination_name': _destinationText,
        'status': 'searching',
        'ride_type': _selectedCard == 0 ? 'Economy' : 'Luxury',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      setState(() => _isSearching = false);

      // الانتقال لشاشة التتبع بعد نجاح الطلب
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RideTrackingScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ في طلب الرحلة: $e")),
      );
    }
  }

  void _confirmDestination(String dest) {
    setState(() {
      _destinationText = dest;
      _isDestinationSelected = true;
    });
    Navigator.pop(context);
  }

  // --- بقية دوال الـ UI (تبقى كما هي مع تحسينات طفيفة) ---

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "إلى أين؟",
                prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (val) {
                if(val.isNotEmpty) _confirmDestination(val);
              },
            ),
            const SizedBox(height: 20),
            _buildResultItem("مول العرب", "مدينة 6 أكتوبر",
                () => _confirmDestination("مول العرب")),
            _buildResultItem("كايرو فيستيفال سيتي", "التجمع الخامس",
                () => _confirmDestination("كايرو فيستيفال سيتي")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentPosition, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            padding: const EdgeInsets.only(bottom: 100), // لإظهار زر الموقع فوق اللوحة
          ),
          // حقل البحث العلوي
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _showSearchModal,
              child: Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15)
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: Color(0xff007AFF), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_destinationText,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black54)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // زر العودة للموقع الحالي
          if (!_isDestinationSelected)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _getCurrentLocation,
                child: const Icon(Icons.my_location, color: Color(0xff007AFF)),
              ),
            ),
          // لوحة اختيار الرحلة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            bottom: _isDestinationSelected ? 0 : -500,
            left: 0,
            right: 0,
            child: _buildBottomRidePanel(),
          ),
          // شاشة التحميل (Searching)
          if (_isSearching)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  // --- بناء لوحة اختيار نوع السيارة ---
  Widget _buildBottomRidePanel() {
    return Container(
      padding: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text("اختر نوع الرحلة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildRideOption(0, "اقتصادية", "120 جـ", "🚗", "3 دقائق"),
          _buildRideOption(1, "سيارة فاخرة", "250 جـ", "🚙", "5 دقائق"),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: _sendRideRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff007AFF),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("تأكيد الرحلة",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideOption(
      int index, String title, String price, String emoji, String time) {
    bool isSelected = _selectedCard == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCard = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? const Color(0xff007AFF) : Colors.transparent,
              width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Text(price,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String title, String sub, VoidCallback onTap) {
    return ListTile(
      trailing: const Icon(Icons.history, color: Colors.grey),
      title: Text(title, textAlign: TextAlign.right),
      subtitle: Text(sub, textAlign: TextAlign.right),
      onTap: onTap,
    );
  }
}