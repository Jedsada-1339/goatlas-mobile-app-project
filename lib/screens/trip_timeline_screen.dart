import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/place_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'create_trip_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _createMarkers();
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
      });
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
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
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
                    const SizedBox(height: 32),

                    // Timeline
                    ...List.generate(_trip.dayPlans.length, (index) {
                      return _buildDaySection(index);
                    }),

                    const SizedBox(height: 80), // Bottom padding
                  ],
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
    );
  }

  Widget _buildDaySection(int index) {
    final dayPlan = _trip.dayPlans[index];
    final date = _trip.startDate?.add(Duration(days: index));
    final String dateText = date != null
        ? '${date.day} ${_getThaiMonth(date.month)}'
        : 'วันที่ ${index + 1}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
