class Room {
  final String id;
  final String name;
  late final String thumbnailImage;
  late final double price;
  final List<String> images;
  final List<String> features;
  final List<String> facilities;
  final List<Map<String, dynamic>> reviews;
  final String description;
  final int adults; // Add adults property
  final int children; // Add children property
  final double area; // Add area property
  final String hotelId;

  Room({
    required this.id,
    required this.name,
    required this.thumbnailImage,
    required this.price,
    required this.images,
    required this.features,
    required this.facilities,
    required this.reviews,
    required this.description,
    required this.adults, // Include adults in constructor
    required this.children, // Include children in constructor
    required this.area, 
    required this.hotelId, // Include area in constructor
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      thumbnailImage: json['thumbnail_image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      reviews: List<Map<String, dynamic>>.from(json['reviews'] ?? []),
      description: json['description'] ?? '',
      adults: json['adults'] ?? 0, // Add default value if not present
      children: json['children'] ?? 0, // Add default value if not present
      area: (json['area'] ?? 0).toDouble(), // Ensure the area is converted to double
      hotelId: json['hotel_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail_image': thumbnailImage,
      'price': price,
      'images': images,
      'features': features,
      'facilities': facilities,
      'reviews': reviews,
      'description': description,
      'adults': adults,
      'children': children,
      'area': area,
      'hotelId': hotelId,
    };
  }
}
