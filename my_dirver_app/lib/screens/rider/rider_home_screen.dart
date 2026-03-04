import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_driver_app/presentation/services/api_service.dart';
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
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  void _confirmDestination(String dest) {
    setState(() {
      _destinationText = dest;
      _isDestinationSelected = true;
    });
    Navigator.pop(context);
  }

  void _sendRideRequest() async {
    setState(() => _isSearching = true);

    try {
      var result = await ApiService.requestRide(
        riderId: 2,
        pLat: _currentPosition.latitude,
        pLng: _currentPosition.longitude,
        dLat: 30.0600,
        dLng: 31.2400,
      );

      if (!mounted) return;

      setState(() => _isSearching = false);

      if (result['status'] == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RideTrackingScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? "No drivers found nearby")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ في الاتصال")),
      );
    }
  }

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
              decoration: InputDecoration(
                hintText: "Enter destination",
                prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (val) => _confirmDestination(val),
            ),
            const SizedBox(height: 20),
            _buildResultItem("Mall of Arabia", "6th of October City",
                () => _confirmDestination("Mall of Arabia")),
            _buildResultItem("Cairo Festival City", "New Cairo",
                () => _confirmDestination("Cairo Festival City")),
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
          ),
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
                    Text(_destinationText,
                        style: const TextStyle(
                            fontSize: 17, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            bottom: _isDestinationSelected ? 0 : -500,
            left: 0,
            right: 0,
            child: _buildBottomRidePanel(),
          ),
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
            child: Text("Choose a ride",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildRideOption(0, "Economy", "384 جـ", "🚗", "3 min away"),
          _buildRideOption(1, "Luxury", "800 جـ", "🚙", "5 min away"),
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
              child: const Text("Confirm Ride",
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
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(title),
      subtitle: Text(sub),
      onTap: onTap,
    );
  }
}
