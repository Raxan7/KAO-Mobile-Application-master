import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/cards/accommodation_room_card.dart';
import '../../models/room.dart';
import '../../utils/constants.dart';
import 'room_detail_page.dart'; // Import the RoomDetailPage
import '../../services/real_time_update_service.dart'; // Import RealTimeUpdateService

class AccommodationRoomList extends StatefulWidget {
  final String accommodationId; // Generalized ID
  final String accommodationName; // Generalized name
  final String accommodationType; // New: Type (e.g., hotel, motel, lodge)

  const AccommodationRoomList({
    super.key,
    required this.accommodationId,
    required this.accommodationName,
    required this.accommodationType, // Pass the type
  });

  @override
  _AccommodationRoomListState createState() => _AccommodationRoomListState();
}

class _AccommodationRoomListState extends State<AccommodationRoomList> {
  List<Room> _rooms = [];
  final RealTimeUpdateService _realTimeUpdateService = RealTimeUpdateService();

  @override
  void initState() {
    super.initState();
    _fetchRooms();

    // Set the onDataUpdated callback
    _realTimeUpdateService.onDataUpdated = (hotels, motels, lodges, hostels, properties) {
      // Fetch the new room data using the accommodation type and ID
      _fetchRooms(); // Call _fetchRooms to refresh the room list
    };

    // Start polling for real-time updates
    _realTimeUpdateService.startPolling();
  }

  Future<void> _fetchRooms() async {
    final response = await http.get(
      Uri.parse('$apiUrl/${widget.accommodationType}_rooms.php?${widget.accommodationType}_id=${widget.accommodationId}'), // Generalized API
    );

    if (response.statusCode == 200) {
      List roomsJson = json.decode(response.body);
      setState(() {
        _rooms = roomsJson.map((room) => Room.fromJson(room)).toList();
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  // Handle booking functionality
  void _bookNow(Room room) {
    // print('Booking room: ${room.name}');
  }

  // Handle more details functionality
  void _moreDetails(BuildContext context, Room room) {
    // Navigate to the RoomDetailPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailPage(
          roomData: {
            'name': room.name,
            'price': room.price,
            'description': room.description,
            'adults': room.adults,
            'children': room.children,
            'area': room.area,
          },
          images: room.images,
          features: room.features,
          facilities: room.facilities,
          reviews: room.reviews,
        ),
      ),
    );
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
        title: Text('${widget.accommodationName} - Rooms'), // Dynamic title
      ),
      body: _rooms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return AccommodationRoomCard(
                  room: room,
                  accommodationType: widget.accommodationType,
                  onBookNow: () => _bookNow(room), // Pass the callback
                  onMoreDetails: (context) {
                    _moreDetails(context, room);
                  }, // Pass the context and room
                );
              },
            ),
    );
  }
}
