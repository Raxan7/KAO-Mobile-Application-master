class UserProperty {
  final String propertyId;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String propertySize;
  final String numberOfRooms;
  final String status;
  final String location;
  final String featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String propertyImage;

  UserProperty({
    required this.propertyId,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.propertySize,
    required this.numberOfRooms,
    required this.status,
    required this.location,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyImage,
  });

  factory UserProperty.fromJson(Map<String, dynamic> json) {
    return UserProperty(
      propertyId: json['property_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      price: double.tryParse(json['price']) ?? 0.0, // Safe parsing for price
      propertySize: json['property_size'],
      numberOfRooms: json['number_of_rooms'],
      status: json['status'],
      location: json['location'],
      featured: json['featured'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      propertyImage: json['property_image'], // Access the image URL
    );
  }
}
