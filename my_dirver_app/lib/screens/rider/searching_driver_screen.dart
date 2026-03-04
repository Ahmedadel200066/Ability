import 'package:flutter/material.dart';

class SearchingDriverScreen extends StatefulWidget {
  final String tripId; // تأكد من وجود هذا السطر

  const SearchingDriverScreen({super.key, required this.tripId});

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Searching for Driver...")),
    );
  }
}
