class NotificationModel {
  final int notificationId;
  final int userId;
  final int propertyId;
  final String message;
  final String status;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.propertyId,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'],
      userId: json['user_id'],
      propertyId: json['property_id'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
