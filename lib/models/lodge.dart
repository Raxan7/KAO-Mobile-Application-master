class Lodge {
  final int id;
  final String name;
  final String location;
  final String description;
  final String thumbnailImage;
  final String businessRegistrationNumber;
  final String businessLicenceNumber;
  final String emergencyContactNumber;
  final String email;
  final int numberOfRooms;
  final int numberOfBeds;
  final String ownerManagerContact;
  final bool lodgeApproved;
  final int ownerId;
  final String? paymentMethod;
  final String? paymentNumber;

  Lodge({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.thumbnailImage,
    required this.businessRegistrationNumber,
    required this.businessLicenceNumber,
    required this.emergencyContactNumber,
    required this.email,
    required this.numberOfRooms,
    required this.numberOfBeds,
    required this.ownerManagerContact,
    required this.lodgeApproved,
    required this.ownerId,
    this.paymentMethod,
    this.paymentNumber,
  });

  factory Lodge.fromJson(Map<String, dynamic> json) {
    return Lodge(
      id: int.parse(json['id']),
      name: json['name'],
      location: json['location'],
      description: json['description'],
      thumbnailImage: json['thumbnail_image'],
      businessRegistrationNumber: json['business_registration_number'],
      businessLicenceNumber: json['business_licence_number'],
      emergencyContactNumber: json['emergency_contact_number'],
      email: json['email'],
      numberOfRooms: int.parse(json['number_of_rooms']),
      numberOfBeds: int.parse(json['number_of_beds']),
      ownerManagerContact: json['owner_manager_contact'],
      lodgeApproved: json['lodge_approved'] == '1',
      ownerId: int.parse(json['owner_id']),
      paymentMethod: json['payment_method'],
      paymentNumber: json['payment_number'],
    );
  }
}
