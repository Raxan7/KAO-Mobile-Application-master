import 'package:flutter/material.dart';
import '../../models/hotel.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remove image since there's no imageUrl in the API response
            const SizedBox(height: 16.0),
            Text(
              hotel.name,
              style: const TextStyle(fontSize: 24),
            ),
            Text(hotel.location),
            const SizedBox(height: 16.0),
            // Remove pricePerNight and replace it with other relevant info
            Text('Number of rooms: ${hotel.numberOfRooms}'),
            Text('Number of beds: ${hotel.numberOfBeds}'),
          ],
        ),
      ),
    );
  }
}
