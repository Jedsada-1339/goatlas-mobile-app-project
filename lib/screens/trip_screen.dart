import 'package:flutter/material.dart';
import 'trips_list_screen.dart';

/// หน้าทริป — redirect ไปหน้ารวมทริปโดยตรง
class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TripsListScreen();
  }
}
