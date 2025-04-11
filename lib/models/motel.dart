class Motel {
  final int id;
  final String name;
  final String location;
  final String description;
  final String thumbnailImage;
  final String? businessRegistrationNumber;
  final String? businessLicenceNumber;
  final String? emergencyContactNumber;
  final String? email;
  final int? numberOfRooms;
  final int? numberOfBeds;
  final String? ownerManagerContact;
  final bool motelApproved;
  final int ownerId;

  Motel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.thumbnailImage,
    this.businessRegistrationNumber,
    this.businessLicenceNumber,
    this.emergencyContactNumber,
    this.email,
    this.numberOfRooms,
    this.numberOfBeds,
    this.ownerManagerContact,
    required this.motelApproved,
    required this.ownerId,
  });

  factory Motel.fromJson(Map<String, dynamic> json) {
    return Motel(
      id: int.parse(json['id']),
      name: json['name'],
      location: json['location'],
      description: json['description'],
      thumbnailImage: json['thumbnail_image'] ?? 'default_thumbnail.png',
      businessRegistrationNumber: json['business_registration_number'],
      businessLicenceNumber: json['business_licence_number'],
      emergencyContactNumber: json['emergency_contact_number'],
      email: json['email'],
      numberOfRooms: json['number_of_rooms'] != null ? int.parse(json['number_of_rooms']) : null,
      numberOfBeds: json['number_of_beds'] != null ? int.parse(json['number_of_beds']) : null,
      ownerManagerContact: json['owner_manager_contact'],
      motelApproved: json['motel_approved'] == '1',
      ownerId: int.parse(json['owner_id']),
    );
  }
}
