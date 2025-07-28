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
  final String? mediaType; // Field to store media type (image/video)

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
    this.mediaType, // Optional, defaults to null
  });

  factory UserProperty.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print('📦 USERPROPERTY MODEL: Parsing JSON = $json');
    
    // Extract media type with fallback
    String? mediaType;
    if (json.containsKey('media_type') && json['media_type'] != null) {
      mediaType = json['media_type'].toString();
      print('📦 USERPROPERTY MODEL: Found media_type = $mediaType');
    } else {
      // For legacy API responses, if we have property_image but no media_type, assume it's an image
      mediaType = 'image';  // Default to image for backward compatibility
      print('📦 USERPROPERTY MODEL: No media_type in JSON, defaulting to "image" for legacy support');
    }
    
    // Safe parsing for dates
    DateTime createdAt;
    DateTime updatedAt;
    
    try {
      createdAt = DateTime.parse(json['created_at']);
      updatedAt = DateTime.parse(json['updated_at']);
    } catch (e) {
      print('❌ USERPROPERTY MODEL ERROR: Failed to parse dates, using current time: $e');
      createdAt = DateTime.now();
      updatedAt = DateTime.now();
    }
    
    // Safe parsing for price
    print("---------------------------------------------------------------------------");
    print('📊 USERPROPERTY MODEL: Full JSON: $json');
    print('📊 USERPROPERTY MODEL: media_type: $mediaType');
    print("---------------------------------------------------------------------------");
    double price = 0.0;
    if (json['price'] != null) {
      try {
        price = double.tryParse(json['price'].toString()) ?? 0.0;
      } catch (e) {
        print('❌ USERPROPERTY MODEL ERROR: Failed to parse price: $e');
      }
    }

    // Get the property image URL
    String propertyImage = json['property_image'] ?? json['media_url'] ?? '';
    
    // Process media URLs based on media type and file extension
    bool isVideoByType = mediaType == 'video';
    bool isVideoByExtension = propertyImage.toLowerCase().endsWith('.mp4') || 
                              propertyImage.toLowerCase().endsWith('.mov') || 
                              propertyImage.toLowerCase().endsWith('.webm');
                              
    // Explicitly handle video URLs
    if (isVideoByType || isVideoByExtension) {
      // Set the media type if it wasn't already set
      if (!isVideoByType) {
        mediaType = 'video';
        print('🎥 USERPROPERTY MODEL: Updated media_type to "video" based on file extension');
      }
      
      // Fix the path for videos regardless of current path
      if (propertyImage.contains('kaoworld.com/')) {
        // Extract the filename from the current URL
        final urlParts = propertyImage.split('/');
        final fileName = urlParts.last;
        
        // Reconstruct with the correct path
        propertyImage = 'https://kaoworld.com/videos/properties/$fileName';
        print('🎥 USERPROPERTY MODEL: Fixed video path: $propertyImage');
      }
    } else if (mediaType == 'image' && propertyImage.contains('videos/properties')) {
      // If it's an image but somehow has videos path, fix it
      propertyImage = propertyImage.replaceAll('videos/properties', 'images/properties');
      print('🖼️ USERPROPERTY MODEL: Fixed image path from videos to images folder: $propertyImage');
    }
    
    return UserProperty(
      propertyId: json['property_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      price: price,
      propertySize: json['property_size'] ?? '',
      numberOfRooms: json['number_of_rooms'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      featured: json['featured'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      propertyImage: propertyImage, // Use the corrected image URL
      mediaType: mediaType, // Field for media type
    );
  }
}
