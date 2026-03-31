import 'package:flutter/material.dart';
import '../components/custom_bottom_nav_bar.dart';

import '../models/trip_model.dart';
import '../models/sample_data.dart';
import '../utills/firebase_service.dart';
import 'create_trip_screen.dart';
import 'trip_timeline_screen.dart';
import '../components/trip_model_card.dart';

/// หน้ารวมทริป - แสดงรายการทริปทั้งหมดจาก Firestore
class TripsListScreen extends StatefulWidget {
  const TripsListScreen({super.key});

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedCategory = 'ทั้งหมด';

  Color get primaryColor => Theme.of(context).colorScheme.primary;

  void _toggleFavorite(TripModel trip) async {
    try {
      await _firebaseService.toggleTripFavorite(trip.id, !trip.isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _deleteTrip(TripModel trip) async {
    try {
      await _firebaseService.deleteTrip(trip.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบทริป "${trip.name}" เรียบร้อยแล้ว'),
            backgroundColor: primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Main Content — StreamBuilder จาก Firestore
            Expanded(
              child: StreamBuilder<List<TripModel>>(
                stream: _firebaseService.getTripsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    );
                  }

                  final trips = snapshot.data ?? [];

                  if (trips.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildTripsList(trips);
                },
              ),
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
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withOpacity(0.8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              // Title
              Text(
                'ทริปของฉัน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
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
                    child: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
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
                  color: isSelected ? primaryColor : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? primaryColor 
                        : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.9)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
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
            Text(
              'ยังไม่มีทริป',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'เริ่มสร้างทริปแรกของคุณเลย!\nวางแผนการเดินทางที่สมบูรณ์แบบ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(List<TripModel> trips) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Section
          _buildStatsSection(trips),
          const SizedBox(height: 24),
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ทริปทั้งหมด',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${trips.length} ทริป',
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Trips List
          ...List.generate(trips.length, (index) {
            // Filter Logic
            if (_selectedCategory != 'ทั้งหมด') {
              bool hasCategory = trips[index].dayPlans.any((day) {
                return day.places.any(
                  (place) => place.category == _selectedCategory,
                );
              });

              if (!hasCategory) return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TripModelCard(
                trip: trips[index],
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TripTimelineScreen(trip: trips[index]),
                    ),
                  );
                  if (result != null && result is TripModel) {
                    // บันทึกทริปที่อัพเดตลง Firestore
                    await _firebaseService.saveTrip(result);
                  }
                },
                onFavoriteToggle: () => _toggleFavorite(trips[index]),
                onDelete: () => _showDeleteConfirmation(trips[index]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsSection(List<TripModel> trips) {
    final totalPlaces = trips.fold<int>(
      0,
      (sum, trip) => sum + trip.totalPlaces,
    );
    final totalDays = trips.fold<int>(0, (sum, trip) => sum + trip.totalDays);

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
            color: primaryColor.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.map_outlined,
            value: '${trips.length}',
            label: 'ทริปทั้งหมด',
          ),
          Container(width: 1, height: 40, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3)),
          _buildStatItem(
            icon: Icons.location_on_outlined,
            value: '$totalPlaces',
            label: 'สถานที่',
          ),
          Container(width: 1, height: 40, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3)),
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
        Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(TripModel trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'ลบทริป',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'ต้องการลบทริป "${trip.name}" หรือไม่?\nการดำเนินการนี้ไม่สามารถย้อนกลับได้',
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(trip);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
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
            // บันทึกทริปใหม่ลง Firestore
            await _firebaseService.saveTrip(result);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
