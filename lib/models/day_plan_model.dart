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

  /// แปลงเป็น Map สำหรับ Firestore
  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'hotelName': hotelName,
      'hotelImageUrl': hotelImageUrl,
      'places': places.map((p) => p.toMap()).toList(),
    };
  }

  /// สร้างจาก Map (Firestore)
  factory DayPlanModel.fromMap(Map<String, dynamic> map) {
    return DayPlanModel(
      dayNumber: map['dayNumber'] ?? 1,
      hotelName: map['hotelName'],
      hotelImageUrl: map['hotelImageUrl'],
      places:
          (map['places'] as List<dynamic>?)
              ?.map(
                (p) => PlaceModel.fromMap(Map<String, dynamic>.from(p as Map)),
              )
              .toList() ??
          [],
    );
  }
}
