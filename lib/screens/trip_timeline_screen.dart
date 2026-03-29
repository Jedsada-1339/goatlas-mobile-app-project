import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/day_plan_model.dart';
import '../models/place_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'create_trip_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'check_in_screen.dart';

class TripTimelineScreen extends StatefulWidget {
  final TripModel trip;

  const TripTimelineScreen({super.key, required this.trip});

  @override
  State<TripTimelineScreen> createState() => _TripTimelineScreenState();
}

class _TripTimelineScreenState extends State<TripTimelineScreen> {
  late TripModel _trip;
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  // Store GlobalKeys for each day section to enable scrolling to them
  final Map<int, GlobalKey> _dayKeys = {};

  // Track selected filter: -1 for All Days, 0..n for specific days
  int _selectedFilter = -1;

  final List<Polyline> _polylines = [];

  // Colors for different days
  final List<Color> _dayColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
  ];

  Color _getColorForDay(int dayIndex) {
    return _dayColors[dayIndex % _dayColors.length];
  }

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _createMarkersAndPolylines();

    // Initialize keys for each day
    for (int i = 0; i < _trip.dayPlans.length; i++) {
      _dayKeys[i] = GlobalKey();
    }
  }

  void _createMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();
    if (_trip.dayPlans.isEmpty) return;

    if (_selectedFilter == -1) {
      // Show all days
      int globalSequence = 1;
      for (int dayIndex = 0; dayIndex < _trip.dayPlans.length; dayIndex++) {
        final dayPlan = _trip.dayPlans[dayIndex];
        final dayColor = _getColorForDay(dayIndex);
        globalSequence = _addDayPlanToMap(
          dayPlan,
          dayColor,
          startingSequence: globalSequence,
        );
      }
    } else if (_selectedFilter < _trip.dayPlans.length) {
      // Show specific day
      final dayPlan = _trip.dayPlans[_selectedFilter];
      final dayColor = _getColorForDay(_selectedFilter);
      _addDayPlanToMap(dayPlan, dayColor, startingSequence: 1);
    }
  }

  int _addDayPlanToMap(
    DayPlanModel dayPlan,
    Color color, {
    int startingSequence = 1,
  }) {
    List<LatLng> dayPoints = [];
    int placeSequence = startingSequence;

    for (var place in dayPlan.places) {
      if (place.latitude != null && place.longitude != null) {
        final point = LatLng(place.latitude!, place.longitude!);
        dayPoints.add(point);
        _addNumberedMarker(place, point, color, placeSequence);
      }
      placeSequence++;
    }

    if (dayPoints.length > 1) {
      _polylines.add(
        Polyline(points: dayPoints, strokeWidth: 4.0, color: color),
      );
    }

    return placeSequence;
  }

  void _addNumberedMarker(
    PlaceModel place,
    LatLng point,
    Color color,
    int sequence,
  ) {
    _markers.add(
      Marker(
        point: point,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Icon(Icons.location_on, color: color, size: 40),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitBounds() {
    if (_markers.isEmpty) return;

    final points = _markers.map((m) => m.point).toList();

    // Check if all coordinates are the same
    bool allSame = true;
    for (int i = 1; i < points.length; i++) {
      if (points[i].latitude != points[0].latitude ||
          points[i].longitude != points[0].longitude) {
        allSame = false;
        break;
      }
    }

    if (allSame) {
      _mapController.move(points[0], 13.0);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _toggleVisited(int dayIndex, int placeIndex) {
    setState(() {
      final dayPlan = _trip.dayPlans[dayIndex];
      final place = dayPlan.places[placeIndex];

      // Update place visited status
      final updatedPlace = place.copyWith(isVisited: !place.isVisited);

      // Update list of places in the day
      final updatedPlaces = List<PlaceModel>.from(dayPlan.places);
      updatedPlaces[placeIndex] = updatedPlace;

      // Update day plan
      final updatedDayPlan = dayPlan.copyWith(places: updatedPlaces);

      // Update list of day plans
      final updatedDayPlans = List.of(_trip.dayPlans);
      updatedDayPlans[dayIndex] = updatedDayPlan;

      // Update trip
      _trip = _trip.copyWith(dayPlans: updatedDayPlans);
    });
  }

  Future<void> _editTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTripScreen(trip: _trip)),
    );

    if (result != null && result is TripModel) {
      setState(() {
        _trip = result;
        // Re-initialize keys if day count changed
        _dayKeys.clear();
        for (int i = 0; i < _trip.dayPlans.length; i++) {
          _dayKeys[i] = GlobalKey();
        }
        _createMarkersAndPolylines();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    }
  }

  void _setFilter(int filterIndex) {
    setState(() {
      _selectedFilter = filterIndex;
      _createMarkersAndPolylines();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
  }

  Future<void> _launchMaps(
    double? startLat,
    double? startLng,
    double endLat,
    double endLng, {
    String? destinationName,
    String? originName,
  }) async {
    final Map<String, String> queryParams = {
      'api': '1',
      'travelmode': 'driving',
    };

    if (destinationName != null && destinationName.isNotEmpty) {
      queryParams['destination'] = destinationName;
    } else {
      queryParams['destination'] = '$endLat,$endLng';
    }

    if (startLat != null && startLng != null) {
      if (originName != null && originName.isNotEmpty) {
        queryParams['origin'] = originName;
      } else {
        queryParams['origin'] = '$startLat,$startLng';
      }
    }

    final Uri url = Uri.https('www.google.com', '/maps/dir/', queryParams);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // Try platform default if external application fails
        if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open maps')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Map Placeholder (Fixed at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              color: const Color(0xFFE2E8F0),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(16.4746, 102.8230), // KKU
                  initialZoom: 13.0,
                  onMapReady: () {
                    if (_markers.isNotEmpty) {
                      _fitBounds();
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.goatlas',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => {}, // OpenStreetMap copyright URL
                      ),
                    ],
                  ),
                  PolylineLayer(polylines: _polylines),
                  MarkerLayer(
                    markers: _markers.isEmpty
                        ? [
                            const Marker(
                              point: LatLng(16.4746, 102.8230),
                              width: 80,
                              height: 80,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  Text(
                                    'KKU',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        : _markers,
                  ),
                ],
              ),
            ),
          ),

          // Timeline Content (Draggable Scroll Sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.47,
            minChildSize: 0.47,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              // Add listener for scroll spy
              // Note: Adding listener here might be tricky because build is called often.
              // But ScrollController is passed by DraggableScrollableSheet, it's persistent.
              // We'll wrap the listener adding in a unique way or just check in a NotificationListener

              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle Bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Trip Title with Edit Button
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _trip.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _trip.dateRangeText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _editTrip,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Day Selector
                      _buildDaySelector(),

                      const SizedBox(height: 16),

                      // Timeline content using Column instead of ListView for SingleChildScrollView
                      if (_selectedFilter == -1)
                        ...List.generate(_trip.dayPlans.length, (index) {
                          return _buildDaySection(index);
                        })
                      else if (_selectedFilter >= 0 &&
                          _selectedFilter < _trip.dayPlans.length)
                        _buildDaySection(_selectedFilter),

                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              );
            },
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _trip),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launchDayRoute,
        icon: const Icon(Icons.map),
        label: Text(_selectedFilter == -1 ? 'นำทางทริปนี้' : 'นำทางวันนี้'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _launchDayRoute() async {
    List<PlaceModel> validPlaces = [];

    if (_selectedFilter == -1) {
      // All days
      for (var day in _trip.dayPlans) {
        validPlaces.addAll(day.places.where((p) => p.name.isNotEmpty));
      }
    } else {
      // Specific day
      final dayPlan = _trip.dayPlans[_selectedFilter];
      validPlaces = dayPlan.places.where((p) => p.name.isNotEmpty).toList();
    }

    if (validPlaces.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่มีสถานที่')));
      return;
    }

    String urlStr;

    if (validPlaces.length == 1) {
      final String destinationStr = Uri.encodeComponent(validPlaces.first.name);
      urlStr =
          'https://www.google.com/maps/dir/?api=1&travelmode=driving&destination=$destinationStr';
    } else {
      final String destinationStr = Uri.encodeComponent(validPlaces.last.name);

      var waypointsList = validPlaces.sublist(0, validPlaces.length - 1);
      // Google Maps supports max 9 waypoints in standard requests
      if (waypointsList.length > 9) {
        waypointsList = waypointsList.sublist(0, 9);
      }

      final String waypointsStr = waypointsList
          .map((p) => Uri.encodeComponent(p.name))
          .join('|');
      urlStr =
          'https://www.google.com/maps/dir/?api=1&travelmode=driving&destination=$destinationStr&waypoints=$waypointsStr';
    }

    final Uri url = Uri.parse(urlStr);

    // Debug: Show URL in dialog before launching so we can verify new code is running
    if (mounted) {
      final shouldLaunch = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('นำทาง Google Maps'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('จำนวนสถานที่: ${validPlaces.length}'),
                const SizedBox(height: 8),
                ...validPlaces.asMap().entries.map(
                  (e) => Text('${e.key + 1}. ${e.value.name}'),
                ),
                const Divider(),
                const Text(
                  'URL:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SelectableText(urlStr, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('เปิดแผนที่'),
            ),
          ],
        ),
      );

      if (shouldLaunch != true) return;
    }

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open maps')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
      }
    }
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _trip.dayPlans.length + 1, // +1 for "All Days"
        itemBuilder: (context, idx) {
          final filterIndex =
              idx - 1; // -1 for All Days, 0..n for specific days
          final isSelected = _selectedFilter == filterIndex;

          return GestureDetector(
            onTap: () => _setFilter(filterIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    filterIndex == -1 ? 'ทั้งหมด' : 'วันที่',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (filterIndex == -1)
                    Icon(
                      Icons.map_outlined,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      size: 24,
                    )
                  else
                    Text(
                      '${filterIndex + 1}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySection(int index) {
    final dayPlan = _trip.dayPlans[index];
    final date = _trip.startDate?.add(Duration(days: index));
    final String dateText = date != null
        ? '${date.day} ${_getThaiMonth(date.month)}'
        : 'วันที่ ${index + 1}';

    return Container(
      key: _dayKeys[index], // Attach GlobalKey
      padding: const EdgeInsets.only(
        top: 16,
      ), // Add padding to offset scroll target
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'วันที่ ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Places List
          if (dayPlan.places.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 24),
              child: Text(
                'ไม่มีแผนการเดินทาง',
                style: TextStyle(color: Colors.grey[400]),
              ),
            )
          else
            Stack(
              children: [
                // Vertical Line
                Positioned(
                  left: 24,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                ),
                Column(
                  children: List.generate(dayPlan.places.length, (placeIndex) {
                    return _buildTimelineItem(
                      dayPlan.places[placeIndex],
                      index,
                      placeIndex,
                    );
                  }),
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(PlaceModel place, int dayIndex, int placeIndex) {
    final bool isLast =
        placeIndex == _trip.dayPlans[dayIndex].places.length - 1;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Marker with Checkbox
          GestureDetector(
            onTap: () => _toggleVisited(dayIndex, placeIndex),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 50,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: place.isVisited
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: place.isVisited
                            ? Theme.of(context).primaryColor
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: place.isVisited
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),

          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (place.latitude != null && place.longitude != null) {
                  final point = LatLng(place.latitude!, place.longitude!);
                  _mapController.move(point, 15.0);
                }
              },
              child: Opacity(
                opacity: place.isVisited ? 0.6 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                                decoration: place.isVisited
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (place.latitude != null && place.longitude != null) ...[
                            GestureDetector(
                              onTap: place.isVisited
                                  ? null
                                  : () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CheckInScreen(place: place),
                                        ),
                                      );
                                      // หากเช็คอินสำเร็จและยังไม่ได้ติ๊ก visited ก็จะปรับสถานะให้
                                      if (result == true && !place.isVisited) {
                                        _toggleVisited(dayIndex, placeIndex);
                                      }
                                    },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: place.isVisited
                                      ? Colors.grey.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_enhance,
                                  size: 16,
                                  color: place.isVisited ? Colors.grey : Colors.green,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Find previous place
                                PlaceModel? prevPlace;
                                if (placeIndex > 0) {
                                  prevPlace = _trip
                                      .dayPlans[dayIndex]
                                      .places[placeIndex - 1];
                                } else if (dayIndex > 0) {
                                  // Look for last place of previous days
                                  for (int d = dayIndex - 1; d >= 0; d--) {
                                    if (_trip.dayPlans[d].places.isNotEmpty) {
                                      prevPlace = _trip.dayPlans[d].places.last;
                                      break;
                                    }
                                  }
                                }

                                _launchMaps(
                                  prevPlace?.latitude,
                                  prevPlace?.longitude,
                                  place.latitude!,
                                  place.longitude!,
                                  destinationName: place.name,
                                  originName: prevPlace?.name,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                          _buildTypeBadge(place.placeType),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'restaurant':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'accommodation':
        icon = Icons.hotel;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.camera_alt;
        color = Theme.of(context).primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  String _getThaiMonth(int month) {
    const thaiMonths = [
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
    return thaiMonths[month];
  }
}
