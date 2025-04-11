class Booking {
  final int id;  // Booking ID
  final String roomName;
  final double price;  // Ensure price is double for consistency
  final DateTime checkIn;
  final DateTime checkOut;
  final String bookingStatus;
  final String bookingId;
  final String orderId;
  final DateTime date;  // Date of booking
  final String hotelId;  // Hotel ID for the booking form
  final String userId;  // User ID for the booking form
  final double totalAmount;  // Total amount for booking calculations

  Booking({
    required this.id,
    required this.roomName,
    required this.price,
    required this.checkIn,
    required this.checkOut,
    required this.bookingStatus,
    required this.bookingId,
    required this.orderId,
    required this.date,
    required this.hotelId,
    required this.userId,
    required this.totalAmount,
  });

  // Factory method to create a Booking object from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      roomName: json['room_name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,  // Ensure price is a double
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      bookingStatus: json['booking_status'] ?? '',
      bookingId: json['booking_id'].toString(),
      orderId: json['order_id'].toString(),
      date: DateTime.parse(json['datentime']),
      hotelId: json['hotel_id'] ?? '',
      userId: json['user_id']?.toString() ?? '',  // Convert user_id to a String
      totalAmount: double.tryParse(json['total_pay'].toString()) ?? 0.0,  // Ensure totalAmount is a double
    );
  }

  // Method to convert Booking object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_name': roomName,
      'price': price,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'booking_status': bookingStatus,
      'booking_id': bookingId,
      'order_id': orderId,
      'datentime': date.toIso8601String(),
      'hotel_id': hotelId,
      'user_id': userId,  // Always a String now
      'total_amount': totalAmount,
    };
  }
}
