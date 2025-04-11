import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../views/user/accommodation_room_list.dart';  // Import the AccomodationRoomList view

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          // Convert the hotel.id (int) to String using .toString()
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccommodationRoomList(
                accommodationId: hotel.id.toString(), 
                accommodationName: hotel.name,
                accommodationType: 'hotel',
              ),  // Convert int to String here
            ),
          );
        },
        child: Card(
          elevation: 5,  // Add more shadow to the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),  // Rounded corners
          ),
          clipBehavior: Clip.antiAlias,  // Ensure rounded corners apply to the image too
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use a default image icon instead of network image
              AspectRatio(
                aspectRatio: 16 / 9,  // Widescreen aspect ratio
                child: Container(
                  color: Colors.blueAccent,
                  alignment: Alignment.center,  // Background color for the placeholder
                  child: Image.network(
                    hotel.thumbnailImage, 
                    width: double.infinity, 
                    height: 200, 
                    fit: BoxFit.cover,  // Make the image cover the entire container
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel name: Adjusted size and color
                    Text(
                      hotel.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white  // White for dark mode
                                : Colors.black87,  // Dark gray for light mode
                          ) ?? const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20),
                    ),
                    
                    const SizedBox(height: 6),  // Spacing between title and subtitle
                    
                    // Hotel location: Smaller, with a subtle color
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hotel.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],  // Use a muted color for better contrast
                          ) ?? TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Number of rooms and beds: Display additional details
                    Row(
                      children: [
                        const Icon(Icons.meeting_room, color: Colors.blueAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.numberOfRooms} rooms',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],  // Use a muted color for better contrast
                          ) ?? TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.bed, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.numberOfBeds} beds',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],  // Use a muted color for better contrast
                          ) ?? TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
