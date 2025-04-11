import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:kao_app/views/dalali/sender_info_page.dart';
import '../../widgets/dalali/dalali_navigation_drawer.dart';
import 'detailed_enquiries_page.dart';
import 'messaging_page.dart'; // Import the detailed enquiries page

class DalaliDashboard extends StatefulWidget {
  final int userId;

  const DalaliDashboard({super.key, required this.userId});

  @override
  _DalaliDashboardState createState() => _DalaliDashboardState();
}

class _DalaliDashboardState extends State<DalaliDashboard> {
  late Future<Map<String, int>> _overview;
  late Future<List<dynamic>> _enquiriesFuture;
  late Future<List<Map<String, dynamic>>>
      _notificationsFuture; // Add notifications future
  final Map<int, String> _userNamesCache = {}; // Cache for user names

  @override
  void initState() {
    super.initState();
    _overview = ApiService.fetchPropertiesOverview(widget.userId);
    _enquiriesFuture = ApiService.fetchUnrepliedEnquiries(widget.userId);
    _notificationsFuture = ApiService.fetchNotifications(
        widget.userId); // Initialize notifications future
  }

  // Function to fetch and cache the user name
  Future<String> _getUserName(int userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!; // Return cached name if available
    } else {
      try {
        // Fetch user details from API and get the name
        final userDetails = await ApiService.fetchUserDetails(userId);
        final userName = userDetails['name'] ?? 'Unknown User';
        _userNamesCache[userId] = userName; // Cache the fetched name
        return userName;
      } catch (e) {
        return 'Unknown User';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dalali Dashboard'),
      ),
      drawer: DalaliNavigationDrawer(
        onThemeChanged: (isDarkMode) {
          setState(() {});
        },
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ), // Add the custom navigation drawer
      body: FutureBuilder<Map<String, int>>(
        future: _overview,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Check your Internet Connection and try again!'),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data;
            print(data);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview of Listings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOverviewCard(
                          'For Sale', data?['for_sale']?.toString() ?? '0'),
                      _buildOverviewCard(
                          'For Rent', data?['for_rent']?.toString() ?? '0'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New Enquiries',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailedEnquiriesPage(
                                    userId: widget.userId),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildEnquiriesList(),
                  // const SizedBox(height: 20),
                  // const Text(
                  //   'Appointments & Bookings',
                  //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 10),
                  // _buildCalendar(),
                  const SizedBox(height: 20),
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _notificationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error loading notifications: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No new notifications'),
                        );
                      } else {
                        return _buildNotifications(snapshot.data!);
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildOverviewCard(String title, String count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 100,
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquiriesList() {
    return FutureBuilder<List<dynamic>>(
      future: _enquiriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No new enquiries'));
        } else {
          final enquiries = snapshot.data!;
          return Column(
            children: enquiries.map((enquiry) {
              return FutureBuilder<String>(
                future: _getUserName(int.parse(enquiry['sender_id'])),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.data ?? 'Loading...';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.message, color: Colors.blue),
                      title: Text('Enquiry from $userName'),
                      subtitle: Text(enquiry['message']),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        if (enquiry['message_id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagingPage(
                                messageId: int.parse(enquiry['message_id']),
                                propertyId: int.parse(enquiry['property_id']),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildCalendar() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Calendar - Upcoming Appointments/Bookings'),
      ),
    );
  }

  Widget _buildNotifications(List<Map<String, dynamic>> notifications) {
    return Column(
      children: notifications.map((notification) {
        final userId = int.parse(notification['user_id']);
        final propertyId = int.parse(notification['property_id']);
        final notificationId = int.parse(notification['notification_id']);

        print(propertyId);

        return FutureBuilder<String>(
          future: _getUserName(userId),
          builder: (context, snapshot) {
            final userName = snapshot.data ?? 'Loading...';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.red),
                title: Text('${notification['message']} by $userName'),
                subtitle: Text(
                  'Received on: ${DateTime.parse(notification['created_at']).toLocal()}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  // Mark the notification as read
                  await ApiService.markNotificationAsRead(notificationId);

                  // Navigate to the SenderInfoPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SenderInfoPage(
                          userId: userId, propertyId: propertyId),
                    ),
                  );
                },
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
