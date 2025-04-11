import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../services/real_time_update_service.dart'; // Import RealTimeUpdateService
import 'package:shared_preferences/shared_preferences.dart';

class BookingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const BookingsPage({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late Future<List<Booking>> _bookings; // Future for bookings
  final ApiService _apiService = ApiService();
  final RealTimeUpdateService _realTimeUpdateService = RealTimeUpdateService();

  @override
  void initState() {
    super.initState();
    _bookings = Future.value([]); // Initialize with an empty list
    _loadBookings(); // Load actual bookings

    // Set the onDataUpdated callback
    _realTimeUpdateService.onDataUpdated = (hotels, motels, lodges, hostels, properties) {
      _loadBookings(); // Call _loadBookings to refresh the booking list
    };

    // Start polling for real-time updates
    _realTimeUpdateService.startPolling();
  }

  Future<void> _loadBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    // Fetch user bookings
    setState(() {
      _bookings = _apiService.fetchUserBookings(userId!);
    });
    }

  // Function to get color based on booking status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return Colors.red; // Red for cancelled
      case 'booked':
        return Colors.green.shade700; // Dark green for booked
      case 'pending':
        return Colors.amber.shade700; // Dark yellow for pending
      case 'under_review':
        return Colors.blue;
      case 'paid':
        return const Color.fromARGB(255, 24, 102, 65);
      default:
        return Colors.black; // Default color
    }
  }

  @override
  void dispose() {
    // Stop polling when the widget is disposed
    _realTimeUpdateService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: FutureBuilder<List<Booking>>(
        future: _bookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          } else {
            final bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.roomName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text('Price: Tsh ${booking.price} per night'),
                          Text('Total Price: Tsh ${booking.totalAmount}'),
                          Text('Check-in: ${booking.checkIn.year}-${booking.checkIn.month}-${booking.checkIn.day}'),
                          Text('Check-out: ${booking.checkOut.year}-${booking.checkOut.month}-${booking.checkOut.day}'),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status: ${booking.bookingStatus}',
                                style: TextStyle(
                                  color: _getStatusColor(booking.bookingStatus), // Apply dynamic color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Add functionality for viewing details or downloading PDF
                                },
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
