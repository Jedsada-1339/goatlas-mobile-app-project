import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/place_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'create_trip_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TripTimelineScreen extends StatefulWidget {
  final TripModel trip;

  const TripTimelineScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripTimelineScreen> createState() => _TripTimelineScreenState();
}

class _TripTimelineScreenState extends State<TripTimelineScreen> {
  late TripModel _trip;
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  // Store GlobalKeys for each day section to enable scrolling to them
  final Map<int, GlobalKey> _dayKeys = {};

  // Track selected day
  int _selectedDay = 0;

  // Flag to prevent scroll listener from interfering with tap-to-scroll
  bool _isprogrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _createMarkers();

    // Initialize keys for each day
    for (int i = 0; i < _trip.dayPlans.length; i++) {
      _dayKeys[i] = GlobalKey();
    }
  }

  void _createMarkers() {
    _markers.clear();
    for (var day in _trip.dayPlans) {
      for (var place in day.places) {
        if (place.latitude != null && place.longitude != null) {
          _markers.add(
            Marker(
              point: LatLng(place.latitude!, place.longitude!),
              width: 80,
              height: 80,
              child: Column(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
  }

  void _fitBounds() {
    if (_markers.isEmpty) return;

    final points = _markers.map((m) => m.point).toList();
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
        _createMarkers();
      });
    }
  }

  void _scrollToDay(int index) {
    if (_dayKeys.containsKey(index)) {
      setState(() {
        _selectedDay = index;
        _isprogrammaticScroll = true;
      });

      Scrollable.ensureVisible(
        _dayKeys[index]!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.05, // Slight offset from top
      ).then((_) {
        _isprogrammaticScroll = false;
      });
    }
  }

  Future<void> _launchMaps(
    double? startLat,
    double? startLng,
    double endLat,
    double endLng,
  ) async {
    final Map<String, String> queryParams = {
      'api': '1',
      'destination': '$endLat,$endLng',
      'travelmode': 'driving',
    };

    if (startLat != null && startLng != null) {
      queryParams['origin'] = '$startLat,$startLng';
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
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _markers.map((m) => m.point).toList(),
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
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

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollUpdateNotification &&
                      !_isprogrammaticScroll) {
                    // Implement Scroll Spy logic here
                    // Check which key is at the top
                    for (int i = 0; i < _trip.dayPlans.length; i++) {
                      final key = _dayKeys[i];
                      if (key?.currentContext != null) {
                        final RenderBox box =
                            key!.currentContext!.findRenderObject()
                                as RenderBox;
                        final Offset position = box.localToGlobal(Offset.zero);

                        // The draggable sheet top is around 40-50% of screen height initially,
                        // or 0 when expanded.
                        // A safe bet is to check if the item is somewhat near the top of the screen.
                        // We can improve this logic, but for now let's say if y is between 100 and 400.
                        // A better way is to check relative to the scroll view viewport, but that's harder to get here.

                        if (position.dy > 100 && position.dy < 400) {
                          if (_selectedDay != i) {
                            setState(() {
                              _selectedDay = i;
                            });
                          }
                          break; // Found the top-most visible one
                        }
                      }
                    }
                  }
                  return false;
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
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
                        ...List.generate(_trip.dayPlans.length, (index) {
                          return _buildDaySection(index);
                        }),

                        const SizedBox(height: 80), // Bottom padding
                      ],
                    ),
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
        label: const Text('นำทางวันนี้'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _launchDayRoute() async {
    final dayPlan = _trip.dayPlans[_selectedDay];
    final placesWithLoc = dayPlan.places
        .where((p) => p.latitude != null && p.longitude != null)
        .toList();

    if (placesWithLoc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่มีสถานที่ที่มีพิกัดในวันนี้')),
      );
      return;
    }

    final Map<String, String> queryParams = {
      'api': '1',
      'travelmode': 'driving',
    };

    // Origin: First place
    final start = placesWithLoc.first;
    // Destination: Last place
    // If only 1 place, logic is tricky for "route". Google Maps Dir needs dest.
    // We set dest = place. Origin = user location (implicit if omitted).
    if (placesWithLoc.length == 1) {
      queryParams['destination'] = '${start.latitude},${start.longitude}';
    } else {
      queryParams['origin'] = '${start.latitude},${start.longitude}';
      final end = placesWithLoc.last;
      queryParams['destination'] = '${end.latitude},${end.longitude}';

      if (placesWithLoc.length > 2) {
        final waypoints = placesWithLoc.sublist(1, placesWithLoc.length - 1);
        queryParams['waypoints'] = waypoints
            .map((p) => '${p.latitude},${p.longitude}')
            .join('|');
      }
    }

    final Uri url = Uri.https('www.google.com', '/maps/dir/', queryParams);

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
        itemCount: _trip.dayPlans.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => _scrollToDay(index),
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
                    'วันที่',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${index + 1}',
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
                        if (place.latitude != null && place.longitude != null)
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
