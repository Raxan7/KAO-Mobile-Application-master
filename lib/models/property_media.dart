class PropertyMedia {
  final String mediaId;
  final String mediaUrl;
  final String mediaType;
  final bool thumb;

  PropertyMedia({
    required this.mediaId,
    required this.mediaUrl,
    required this.mediaType,
    required this.thumb,
  });

  factory PropertyMedia.fromJson(Map<String, dynamic> json) {
    // Adding null checks and validation for each field
    return PropertyMedia(
      mediaId: json['media_id']?.toString() ?? 'Unknown ID',
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'Unknown type',
      thumb: json['thumb'] == 1,
    );
  }
}
