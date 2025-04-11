import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/room.dart';
import '../../services/api_service.dart'; // Import the ApiService
import '../../services/real_time_update_service.dart'; // Import the RealTimeUpdateService
import '../../views/user/room_detail_page.dart'; // Import the RoomDetailPage
import '../../views/user/booking_form.dart'; // Import the BookingFormPage

class AccommodationRoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback onBookNow;
  final String accommodationType; // Generalized accommodation type (e.g., hotel, motel)

  const AccommodationRoomCard({
    super.key,
    required this.room,
    required this.onBookNow,
    required Null Function(dynamic context) onMoreDetails,
    required this.accommodationType,  // Pass the type of accommodation
  });

  @override
  _AccommodationRoomCardState createState() => _AccommodationRoomCardState();
}

class _AccommodationRoomCardState extends State<AccommodationRoomCard> {
  final ApiService _apiService = ApiService();
  final RealTimeUpdateService _realTimeUpdateService = RealTimeUpdateService(); // Instance of RealTimeUpdateService

  @override
  void initState() {
    super.initState();

    // Set the onDataUpdated callback
    _realTimeUpdateService.onDataUpdated = (hotels, motels, lodges, hostels, properties) {
      _refreshRoomDetails(); // Refresh room details on data update
    };

    // Start polling for real-time updates
    _realTimeUpdateService.startPolling();
  }

  Future<void> _refreshRoomDetails() async {
    try {
      final roomDetails = await _apiService.fetchRoomDetails(widget.room.id, widget.accommodationType);
      setState(() {
        // Update the room with the latest details (you might need to adjust this according to your Room model)
        widget.room.price = roomDetails['price']; // Update other necessary fields
        widget.room.thumbnailImage = roomDetails['thumbnailImage']; // Example
        // Add any additional properties you want to update
      });
    } catch (error) {
      // print('Error refreshing room details: $error');
    }
  }

  Future<void> _bookNow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Check if the user is logged in

    if (token == null) {
      // If not logged in, redirect to the login page
      Navigator.pushNamed(context, '/login');
    } else {
      // Navigate to the booking form page with the room information
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingFormPage(room: widget.room), // Pass the room to the booking page
        ),
      );
    }
  }

  // Fetch room details from API and navigate to RoomDetailPage
  Future<void> _showRoomDetails(BuildContext context) async {
    try {
      final roomDetails = await _apiService.fetchRoomDetails(widget.room.id, widget.accommodationType);  // Generalized fetch

      // Navigate to RoomDetailPage with fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomDetailPage(
            roomData: roomDetails,
            images: List<String>.from(roomDetails['images'] ?? []),
            features: List<String>.from(roomDetails['features'] ?? []),
            facilities: List<String>.from(roomDetails['facilities'] ?? []),
            reviews: List<Map<String, dynamic>>.from(roomDetails['reviews'] ?? []),
          ),
        ),
      );
    } catch (error) {
      // print('Error fetching room details: $error');
      // Show error dialog if needed
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.room.thumbnailImage,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room name
                  Text(
                    widget.room.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 6),

                  // Room price
                  Text(
                    'Tsh ${widget.room.price} per night',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 6),

                  // Buttons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Book Now Button with login check
                      ElevatedButton(
                        onPressed: () => _bookNow(context), // Navigate to booking page
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // More Details Button
                      OutlinedButton(
                        onPressed: () => _showRoomDetails(context), // Fetch and show room details
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[300],
                          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: 2,
                        ),
                        child: const Text(
                          'More Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
