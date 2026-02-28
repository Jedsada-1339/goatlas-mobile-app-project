class Destination {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String category;
  final bool isFavorite;
  final double rating;
  final String description;
  final double? latitude;
  final double? longitude;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
    this.rating = 0.0,
    this.description = '',
    this.latitude,
    this.longitude,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    // ดึง URL รูปภาพ — ลองหลาย field ตาม TAT API v2 schema
    String mappedImageUrl = '';

    // 1) thumbnailUrl เป็น Array<String> ใน PlaceList endpoint
    if (json['thumbnailUrl'] is List &&
        (json['thumbnailUrl'] as List).isNotEmpty) {
      mappedImageUrl = (json['thumbnailUrl'] as List).first.toString();
    }
    // 2) thumbnailUrl เป็น String ใน PlaceDetails endpoint
    else if (json['thumbnailUrl'] is String &&
        (json['thumbnailUrl'] as String).isNotEmpty) {
      mappedImageUrl = json['thumbnailUrl'] as String;
    }
    // 3) sha.thumbnailUrl (String)
    else if (json['sha'] is Map &&
        json['sha']['thumbnailUrl'] != null &&
        json['sha']['thumbnailUrl'].toString().isNotEmpty) {
      mappedImageUrl = json['sha']['thumbnailUrl'].toString();
    }
    // 4) desktopImageUrls (PlaceDetails endpoint)
    else if (json['desktopImageUrls'] is List &&
        (json['desktopImageUrls'] as List).isNotEmpty) {
      mappedImageUrl = (json['desktopImageUrls'] as List).first.toString();
    }
    // 5) mobileImageUrls (PlaceDetails endpoint)
    else if (json['mobileImageUrls'] is List &&
        (json['mobileImageUrls'] as List).isNotEmpty) {
      mappedImageUrl = (json['mobileImageUrls'] as List).first.toString();
    }

    // ดึงหมวดหมู่จาก object: "category": {"name": "สถานที่ท่องเที่ยว"}
    final categoryRaw = json['category'];
    final String category = categoryRaw is Map
        ? (categoryRaw['name'] as String? ?? 'สถานที่ท่องเที่ยว')
        : (categoryRaw?.toString() ?? 'สถานที่ท่องเที่ยว');

    // ดึง location — TAT API ส่ง location เป็น object ที่มี province, district และพิกัด
    final locationRaw = json['location'];
    String location = 'ประเทศไทย';
    double? latitude;
    double? longitude;

    if (locationRaw is Map) {
      // ดึงพิกัดจาก location
      if (locationRaw['latitude'] != null) {
        latitude = double.tryParse(locationRaw['latitude'].toString());
      }
      if (locationRaw['longitude'] != null) {
        longitude = double.tryParse(locationRaw['longitude'].toString());
      }

      // province เป็น Map: {provinceId: 464, name: "ชลบุรี"}
      final province = locationRaw['province'];
      final district = locationRaw['district'];
      final provinceName = province is Map
          ? province['name']?.toString()
          : province?.toString();
      final districtName = district is Map
          ? district['name']?.toString()
          : district?.toString();

      if (provinceName != null && provinceName.isNotEmpty) {
        if (districtName != null && districtName.isNotEmpty) {
          location = '$districtName, $provinceName';
        } else {
          location = provinceName;
        }
      } else if (locationRaw['address'] != null &&
          locationRaw['address'].toString().isNotEmpty) {
        location = locationRaw['address'].toString();
      }
    } else if (locationRaw is String && locationRaw.isNotEmpty) {
      location = locationRaw;
    }

    // Fallback ดึงพิกัดจาก Root ถ้ายางที่ location ไม่มีพิกัด
    if (latitude == null && json['latitude'] != null) {
      latitude = double.tryParse(json['latitude'].toString());
    }
    if (longitude == null && json['longitude'] != null) {
      longitude = double.tryParse(json['longitude'].toString());
    }

    // ดึงรายละเอียดจาก sha.detail หรือ introduction
    final shaRaw = json['sha'];
    final String description =
        (shaRaw is Map ? shaRaw['detail']?.toString() : null) ??
        json['introduction']?.toString() ??
        '';

    return Destination(
      id:
          json['placeId']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? 'Unknown Place',
      location: location,
      imageUrl: mappedImageUrl,
      category: category,
      rating: 4.5,
      description: description,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Destination copyWith({
    String? id,
    String? name,
    String? location,
    String? imageUrl,
    String? category,
    bool? isFavorite,
    double? rating,
    String? description,
    double? latitude,
    double? longitude,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
