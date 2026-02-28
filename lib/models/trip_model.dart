import 'package:cloud_firestore/cloud_firestore.dart';
import 'day_plan_model.dart';
import 'place_model.dart';

/// Model สำหรับทริป
class TripModel {
  final String id;
  final String name;
  final String coverImageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DayPlanModel> dayPlans;
  final bool isFavorite;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.name,
    this.coverImageUrl = '',
    this.startDate,
    this.endDate,
    this.dayPlans = const [],
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TripModel copyWith({
    String? id,
    String? name,
    String? coverImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<DayPlanModel>? dayPlans,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dayPlans: dayPlans ?? this.dayPlans,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// จำนวนวัน
  int get totalDays => dayPlans.length;

  /// จำนวนสถานที่ทั้งหมด
  int get totalPlaces => dayPlans.fold(0, (sum, day) => sum + day.placeCount);

  /// วันที่ในรูปแบบ string
  String get dateRangeText {
    if (startDate == null || endDate == null) return 'ยังไม่กำหนดวันที่';

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

    final start = '${startDate!.day} ${thaiMonths[startDate!.month]}';
    final end =
        '${endDate!.day} ${thaiMonths[endDate!.month]} ${endDate!.year + 543}';

    return '$start - $end';
  }

  /// เพิ่มวันใหม่
  TripModel addDay() {
    final newDay = DayPlanModel(dayNumber: dayPlans.length + 1);
    return copyWith(dayPlans: [...dayPlans, newDay]);
  }

  /// ลบวัน
  TripModel removeDay(int dayNumber) {
    if (dayPlans.length <= 1) return this; // ต้องมีอย่างน้อย 1 วัน

    final newDays = dayPlans
        .where((d) => d.dayNumber != dayNumber)
        .toList()
        .asMap()
        .entries
        .map((e) => e.value.copyWith(dayNumber: e.key + 1))
        .toList();

    return copyWith(dayPlans: newDays);
  }

  /// เพิ่มสถานที่ในวันที่กำหนด
  TripModel addPlaceToDay(int dayNumber, PlaceModel place) {
    final newDays = dayPlans.map((day) {
      if (day.dayNumber == dayNumber) {
        return day.addPlace(place);
      }
      return day;
    }).toList();

    return copyWith(dayPlans: newDays);
  }

  /// ลบสถานที่ในวันที่กำหนด
  TripModel removePlaceFromDay(int dayNumber, String placeId) {
    final newDays = dayPlans.map((day) {
      if (day.dayNumber == dayNumber) {
        return day.removePlace(placeId);
      }
      return day;
    }).toList();

    return copyWith(dayPlans: newDays);
  }

  /// แปลงเป็น Map สำหรับ Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'coverImageUrl': coverImageUrl,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'dayPlans': dayPlans.map((d) => d.toMap()).toList(),
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// สร้างจาก Firestore document
  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    return TripModel(
      id: id,
      name: map['name'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      dayPlans:
          (map['dayPlans'] as List<dynamic>?)
              ?.map(
                (d) =>
                    DayPlanModel.fromMap(Map<String, dynamic>.from(d as Map)),
              )
              .toList() ??
          [],
      isFavorite: map['isFavorite'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
