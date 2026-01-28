import 'place_model.dart';

/// Model สำหรับแผนวัน (สถานที่ที่จะไปในแต่ละวัน)
class DayPlanModel {
  final int dayNumber;
  final List<PlaceModel> places;
  final String? hotelName;
  final String? hotelImageUrl;

  DayPlanModel({
    required this.dayNumber,
    this.places = const [],
    this.hotelName,
    this.hotelImageUrl,
  });

  DayPlanModel copyWith({
    int? dayNumber,
    List<PlaceModel>? places,
    String? hotelName,
    String? hotelImageUrl,
  }) {
    return DayPlanModel(
      dayNumber: dayNumber ?? this.dayNumber,
      places: places ?? this.places,
      hotelName: hotelName ?? this.hotelName,
      hotelImageUrl: hotelImageUrl ?? this.hotelImageUrl,
    );
  }

  /// เพิ่มสถานที่
  DayPlanModel addPlace(PlaceModel place) {
    return copyWith(places: [...places, place]);
  }

  /// ลบสถานที่
  DayPlanModel removePlace(String placeId) {
    return copyWith(places: places.where((p) => p.id != placeId).toList());
  }

  /// จำนวนสถานที่
  int get placeCount => places.length;
}
