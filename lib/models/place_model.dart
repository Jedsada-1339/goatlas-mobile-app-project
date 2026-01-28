/// Model สำหรับสถานที่ท่องเที่ยว
class PlaceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final String location;
  final double rating;
  final String duration;
  final double? latitude;
  final double? longitude;

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.location,
    this.rating = 0.0,
    this.duration = '1-2 ชม.',
    this.latitude,
    this.longitude,
  });

  PlaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    String? location,
    double? rating,
    String? duration,
    double? latitude,
    double? longitude,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'location': location,
      'rating': rating,
      'duration': duration,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? '1-2 ชม.',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }
}
