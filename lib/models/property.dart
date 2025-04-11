import 'property_media.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String size;
  final int numberOfRooms;
  final String status;
  final String location;
  final bool featured;
  final List<PropertyMedia> media;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.size,
    required this.numberOfRooms,
    required this.status,
    required this.location,
    required this.featured,
    required this.media,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Adding null checks and validation for each field
    return Property(
      id: json['property_id'].toString(),
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? 'No description available',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      size: json['property_size'] ?? 'Unknown size',
      numberOfRooms: int.tryParse(json['number_of_rooms'].toString()) ?? 0,
      status: json['status'] ?? 'Unknown status',
      location: json['location'] ?? 'No location available',
      featured: json['featured'] == 1,
      media: (json['media'] as List<dynamic>? ?? [])
          .map((item) => PropertyMedia.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
