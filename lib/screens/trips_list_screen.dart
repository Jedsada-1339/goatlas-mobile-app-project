import 'package:flutter/material.dart';
import '../components/custom_bottom_nav_bar.dart';

import '../models/trip_model.dart';
import '../models/sample_data.dart';
import 'create_trip_screen.dart';
import 'trip_timeline_screen.dart';
import '../components/trip_model_card.dart';

/// หน้ารวมทริป - แสดงรายการทริปทั้งหมด
class TripsListScreen extends StatefulWidget {
  const TripsListScreen({Key? key}) : super(key: key);

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  // ใช้ข้อมูลจาก SampleData
  late List<TripModel> _trips;
  String _selectedCategory = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    _trips = List.from(SampleData.trips);
  }

  Color get primaryColor => Theme.of(context).primaryColor;

  void _toggleFavorite(int index) {
    setState(() {
      _trips[index] = _trips[index].copyWith(
        isFavorite: !_trips[index].isFavorite,
      );
    });
  }

  void _deleteTrip(int index) {
    final tripName = _trips[index].name;
    setState(() {
      _trips.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ลบทริป "$tripName" เรียบร้อยแล้ว'),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Main Content
            Expanded(
              child: _trips.isEmpty ? _buildEmptyState() : _buildTripsList(),
            ),
          ],
        ),
      ),
      // Create Trip Button
      floatingActionButton: _buildCreateTripButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                // child: Material(
                //   color: Colors.transparent,
                //   child: InkWell(
                //     borderRadius: BorderRadius.circular(20),
                //     onTap: () => Navigator.pop(context),
                //     child: const Icon(
                //       Icons.chevron_left,
                //       color: Color(0xFF64748B),
                //     ),
                //   ),
                // ),
              ),
              // Title
              const Text(
                'ทริปของฉัน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              // More Options
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Category Chips
        _buildCategoryChips(),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white.withOpacity(0.5),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: SampleData.placeCategories.length,
        itemBuilder: (context, index) {
          final category = SampleData.placeCategories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 80,
                color: primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ยังไม่มีทริป',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'เริ่มสร้างทริปแรกของคุณเลย!\nวางแผนการเดินทางที่สมบูรณ์แบบ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Section
          _buildStatsSection(),
          const SizedBox(height: 24),
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ทริปทั้งหมด',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${_trips.length} ทริป',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Trips List
          ...List.generate(_trips.length, (index) {
            // Filter Logic
            if (_selectedCategory != 'ทั้งหมด') {
              bool hasCategory = _trips[index].dayPlans.any((day) {
                return day.places.any(
                  (place) => place.category == _selectedCategory,
                );
              });

              if (!hasCategory) return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TripModelCard(
                trip: _trips[index],
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TripTimelineScreen(trip: _trips[index]),
                    ),
                  );
                  if (result != null && result is TripModel) {
                    setState(() {
                      _trips[index] = result;
                    });
                  }
                },
                onFavoriteToggle: () => _toggleFavorite(index),
                onDelete: () => _showDeleteConfirmation(index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final totalPlaces = _trips.fold<int>(
      0,
      (sum, trip) => sum + trip.totalPlaces,
    );
    final totalDays = _trips.fold<int>(0, (sum, trip) => sum + trip.totalDays);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.map_outlined,
            value: '${_trips.length}',
            label: 'ทริปทั้งหมด',
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(
            icon: Icons.location_on_outlined,
            value: '$totalPlaces',
            label: 'สถานที่',
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(
            icon: Icons.calendar_today_outlined,
            value: '$totalDays',
            label: 'วันทั้งหมด',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'ลบทริป',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'ต้องการลบทริป "${_trips[index].name}" หรือไม่?\nการดำเนินการนี้ไม่สามารถย้อนกลับได้',
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'ลบ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTripButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTripScreen()),
          );
          if (result != null && result is TripModel) {
            setState(() {
              _trips.add(result);
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20),
            SizedBox(width: 8),
            Text(
              'สร้างทริปใหม่',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
