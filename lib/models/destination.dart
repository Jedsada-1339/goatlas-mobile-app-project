class Destination {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String category;
  final bool isFavorite;
  final double rating;
  final String description;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
    this.rating = 0.0,
    this.description = '',
  });

  Destination copyWith({
    String? id,
    String? name,
    String? location,
    String? imageUrl,
    String? category,
    bool? isFavorite,
    double? rating,
    String? description,
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
    );
  }
}
