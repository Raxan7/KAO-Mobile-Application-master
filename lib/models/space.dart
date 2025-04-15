class Space {
  final String id;
  final String userId;
  final String categoryId;
  final String subcategoryId;
  final String title;
  final String description;
  final String status;
  final bool featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;
  final String? contactInfo;
  final String? websiteUrl;
  final Map<String, dynamic>? socialLinks;
  final String categoryName;
  final String subcategoryName;
  final String? thumbnail;
  final List<SpaceMedia> media;

  Space({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.subcategoryId,
    required this.title,
    required this.description,
    required this.status,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.contactInfo,
    this.websiteUrl,
    this.socialLinks,
    required this.categoryName,
    required this.subcategoryName,
    this.thumbnail,
    required this.media,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['space_id'].toString(),
      userId: json['user_id'].toString(),
      categoryId: json['category_id'].toString(),
      subcategoryId: json['subcategory_id'].toString(),
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? 'No description available',
      status: json['status'] ?? 'pending',
      featured: json['featured'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      location: json['location'],
      contactInfo: json['contact_info'],
      websiteUrl: json['website_url'],
      socialLinks: json['social_links'] != null 
          ? Map<String, dynamic>.from(json['social_links'])
          : null,
      categoryName: json['category_name'] ?? 'Uncategorized',
      subcategoryName: json['subcategory_name'] ?? 'Uncategorized',
      thumbnail: json['thumbnail'],
      media: (json['media'] as List<dynamic>? ?? [])
          .map((item) => SpaceMedia.fromJson(item))
          .toList(),
    );
  }
}

class SpaceMedia {
  final String id;
  final String spaceId;
  final String mediaUrl;
  final String mediaType;
  final bool thumb;
  final DateTime createdAt;

  SpaceMedia({
    required this.id,
    required this.spaceId,
    required this.mediaUrl,
    required this.mediaType,
    required this.thumb,
    required this.createdAt,
  });

  factory SpaceMedia.fromJson(Map<String, dynamic> json) {
    return SpaceMedia(
      id: json['media_id'].toString(),
      spaceId: json['space_id'].toString(),
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      thumb: json['thumb'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}