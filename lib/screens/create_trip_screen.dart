import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/cached_image_with_placeholder.dart';
import '../models/trip_model.dart';
import '../models/day_plan_model.dart';
import '../models/place_model.dart';
import 'add_place_screen.dart';

/// หน้าสร้าง/แก้ไขทริป
class CreateTripScreen extends StatefulWidget {
  final TripModel? trip;

  const CreateTripScreen({super.key, this.trip});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  int _selectedDay = 1;
  final TextEditingController _tripNameController = TextEditingController();
  late TripModel _currentTrip;
  bool _isEditing = false;
  DateTimeRange? _selectedDateRange;
  String? _localImagePath; // รูปปกจากเครื่อง
  final ImagePicker _imagePicker = ImagePicker();

  Color get primaryColor => Theme.of(context).primaryColor;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _currentTrip = widget.trip!;
      _tripNameController.text = _currentTrip.name;
      _isEditing = true;
      if (_currentTrip.startDate != null && _currentTrip.endDate != null) {
        _selectedDateRange = DateTimeRange(
          start: _currentTrip.startDate!,
          end: _currentTrip.endDate!,
        );
      }
    } else {
      // สร้างทริปใหม่พร้อม 3 วันเริ่มต้น
      _currentTrip = TripModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        coverImageUrl: '',
        dayPlans: [
          DayPlanModel(dayNumber: 1),
          DayPlanModel(dayNumber: 2),
          DayPlanModel(dayNumber: 3),
        ],
      );
    }
  }

  /// เลือกรูปปกจากแกลเลอรี่หรือกล้อง
  Future<void> _pickCoverImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'เลือกรูปปก',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library, color: primaryColor),
                ),
                title: const Text('เลือกจากแกลเลอรี่'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1200,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _localImagePath = image.path;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error picking image: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, color: primaryColor),
                ),
                title: const Text('ถ่ายรูป'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1200,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _localImagePath = image.path;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error taking photo: $e')),
                      );
                    }
                  }
                },
              ),
              if (_localImagePath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text('ลบรูปปก'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _localImagePath = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// หา cover image URL ที่จะใช้  (ลำดับ: รูปที่เลือก > รูปสถานที่แรก > ค่าว่าง)
  String get _effectiveCoverImageUrl {
    // ถ้ามีรูปปกจากเครื่องจะใช้ตอน display
    if (_localImagePath != null) return '';
    // ถ้ามี coverImageUrl อยู่แล้ว
    if (_currentTrip.coverImageUrl.isNotEmpty)
      return _currentTrip.coverImageUrl;
    // ใช้รูปจากสถานที่แรกที่เพิ่มมา
    for (final day in _currentTrip.dayPlans) {
      for (final place in day.places) {
        if (place.imageUrl.isNotEmpty) return place.imageUrl;
      }
    }
    return '';
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    super.dispose();
  }

  DayPlanModel get _currentDayPlan {
    if (_selectedDay <= _currentTrip.dayPlans.length) {
      return _currentTrip.dayPlans[_selectedDay - 1];
    }
    return DayPlanModel(dayNumber: _selectedDay);
  }

  void _addPlaceToCurrentDay(PlaceModel place) {
    setState(() {
      _currentTrip = _currentTrip.addPlaceToDay(_selectedDay, place);
    });
  }

  void _removePlaceFromCurrentDay(String placeId) {
    setState(() {
      _currentTrip = _currentTrip.removePlaceFromDay(_selectedDay, placeId);
    });
  }

  Future<void> _selectDates() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentTrip = _currentTrip.copyWith(
          startDate: picked.start,
          endDate: picked.end,
        );

        final duration = picked.end.difference(picked.start).inDays + 1;
        _updateTripDuration(duration);
      });
    }
  }

  void _updateTripDuration(int newDuration) {
    int currentDuration = _currentTrip.dayPlans.length;
    if (newDuration > currentDuration) {
      for (int i = 0; i < newDuration - currentDuration; i++) {
        _currentTrip = _currentTrip.addDay();
      }
    } else if (newDuration < currentDuration) {
      for (int i = 0; i < currentDuration - newDuration; i++) {
        _currentTrip = _currentTrip.removeDay(_currentTrip.dayPlans.length);
      }
      if (_selectedDay > _currentTrip.dayPlans.length) {
        _selectedDay = _currentTrip.dayPlans.length;
      }
    }
  }

  String _formatDate(DateTime date) {
    final thaiMonths = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${date.day} ${thaiMonths[date.month]}';
  }

  void _saveTrip() {
    if (_tripNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาใส่ชื่อทริป'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // ถ้าผู้ใช้ไม่เลือกรูปปก ใช้รูปสถานที่แรก
    String coverUrl = _currentTrip.coverImageUrl;
    if (_localImagePath != null) {
      coverUrl = _localImagePath!;
    } else if (coverUrl.isEmpty) {
      coverUrl = _effectiveCoverImageUrl;
    }

    final savedTrip = _currentTrip.copyWith(
      name: _tripNameController.text,
      coverImageUrl: coverUrl,
    );

    Navigator.pop(context, savedTrip);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'บันทึกทริปเรียบร้อยแล้ว' : 'สร้างทริปสำเร็จ!',
        ),
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Image
                    _buildCoverImage(),
                    const SizedBox(height: 24),
                    // Trip Name Input
                    _buildTripNameInput(),
                    const SizedBox(height: 24),
                    // Day Selector
                    _buildDaySelector(),
                    const SizedBox(height: 32),
                    // Timeline
                    _buildTimeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Save Trip Button
      floatingActionButton: _buildSaveTripButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left, color: Color(0xFF64748B)),
              ),
            ),
          ),
          // Title
          Text(
            _isEditing ? 'แก้ไขทริป' : 'สร้างทริปใหม่',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: Color(0xFF0F172A),
            ),
          ),
          // Placeholder for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    final bool hasLocalImage = _localImagePath != null;
    final String networkUrl = _effectiveCoverImageUrl;
    final bool hasAnyImage = hasLocalImage || networkUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _pickCoverImage,
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFE2E8F0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: hasLocalImage
                    ? Image.file(
                        File(_localImagePath!),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    : hasAnyImage
                    ? CachedImageWithPlaceholder(
                        imageUrl: networkUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorWidget: _buildPlaceholderIcon(),
                      )
                    : _buildPlaceholderIcon(),
              ),
              // Gradient Overlay
              if (hasAnyImage)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              // Change Cover Button
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, size: 16, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        hasAnyImage ? 'เปลี่ยนรูปปก' : 'เพิ่มรูปปก',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'แตะเพื่อเพิ่มรูปปก',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripNameInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ชื่อทริป',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _tripNameController,
              style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'เช่น เชียงใหม่ 3 วัน 2 คืน',
                hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Date Picker
          GestureDetector(
            onTap: _selectDates,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: _currentTrip.startDate != null
                        ? primaryColor
                        : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentTrip.dateRangeText,
                    style: TextStyle(
                      fontSize: 16,
                      color: _currentTrip.startDate != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                      fontWeight: _currentTrip.startDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: _currentTrip.dayPlans.length,
        itemBuilder: (context, index) {
          return _buildDayItem(index + 1);
        },
      ),
    );
  }

  Widget _buildDayItem(int day) {
    final isSelected = _selectedDay == day;
    final dayPlan = _currentTrip.dayPlans[day - 1];
    final placeCount = dayPlan.places.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        width: 96,
        height: 96,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentTrip.startDate != null
                        ? _formatDate(
                            _currentTrip.startDate!.add(
                              Duration(days: day - 1),
                            ),
                          )
                        : 'วันที่',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xFF94A3B8),
                      letterSpacing: 1, // Reduced spacing
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  if (placeCount > 0)
                    Text(
                      '$placeCount สถานที่',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final dayPlan = _currentDayPlan;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'กำหนดการวันที่ $_selectedDay',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${dayPlan.places.length} สถานที่',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hotel

          // Places
          ...List.generate(
            dayPlan.places.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPlaceItem(dayPlan.places[index], index + 1),
            ),
          ),
          // Add Place Button
          _buildAddPlaceItem(dayPlan.places.length + 1),
        ],
      ),
    );
  }

  Widget _buildPlaceItem(PlaceModel place, int number) {
    IconData typeIcon = Icons.camera_alt;
    Color typeColor = primaryColor;
    String typeLabel = 'ท่องเที่ยว';

    if (place.placeType == 'restaurant') {
      typeIcon = Icons.restaurant;
      typeColor = Colors.orange;
      typeLabel = 'ร้านอาหาร';
    } else if (place.placeType == 'accommodation') {
      typeIcon = Icons.hotel;
      typeColor = Colors.indigo;
      typeLabel = 'ที่พัก';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            shape: BoxShape.rectangle, // Changed from circle
            borderRadius: BorderRadius.circular(16), // Rounded corners
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: Icon(typeIcon, color: typeColor, size: 20)),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC), // Lighter background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              // Removed shadow for flatter look
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Label
                      Text(
                        typeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Place Name
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Location & Duration
                      Text(
                        '${place.location} • ${place.duration}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete Button
                GestureDetector(
                  onTap: () => _removePlaceFromCurrentDay(place.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPlaceItem(int number) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number Circle
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Add Button
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
              );
              if (result != null && result is PlaceModel) {
                _addPlaceToCurrentDay(result);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('เพิ่ม "${result.name}" เรียบร้อยแล้ว'),
                    backgroundColor: primaryColor,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_location_alt,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'เพิ่มสถานที่...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveTripButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isEditing ? 'บันทึกทริป' : 'สร้างทริป',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
