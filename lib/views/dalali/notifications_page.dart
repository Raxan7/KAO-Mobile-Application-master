import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import 'sender_info_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatelessWidget {
  final int targetUserId;

  const NotificationsPage({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF3571C1),
      ),
      body: RefreshIndicator( // Pull to refresh
        onRefresh: () async {
          // Implement your refresh logic here (e.g., call setState if using StatefulWidget)
          await Future.delayed(const Duration(seconds: 1)); // Placeholder delay
        },
        child: FutureBuilder<List<NotificationModel>>(
          future: ApiService.fetchNotificationsAll(targetUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading notifications: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No notifications available.'));
            }

            final notifications = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification.status == 'Read';

                return FutureBuilder<Map<String, dynamic>>(
                  future: ApiService.fetchPropertyDetailForUser(notification.propertyId),
                  builder: (context, propertySnapshot) {
                    if (propertySnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Loading property details...'),
                        leading: CircularProgressIndicator(), // Loading indicator
                      );
                    } else if (propertySnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${propertySnapshot.error}'),
                        tileColor: Colors.red[100],
                      );
                    }

                    final property = propertySnapshot.data!;
                    final propertyName = property['title'] ?? 'Unknown Property';
                    final propertyImage = (property['property_image'][0]).toString();



                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SenderInfoPage(
                              userId: notification.userId,
                              propertyId: notification.propertyId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          height: 150,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: Image.network(
                                  propertyImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.house),

                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(propertyName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        )),
                                    const SizedBox(height: 8),
                                    Text(
                                      notification.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      timeago.format(notification.createdAt.add(const Duration(hours: 8))),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
