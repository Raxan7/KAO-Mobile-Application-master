import 'package:flutter/material.dart';

// Define a reusable card widget for accommodation (e.g., hotels, motels, lodges)
class SimpleAccommodationCard extends StatelessWidget {
  final dynamic accommodation;  // Accepts a generalized accommodation type
  final Widget Function() roomListPage;

  const SimpleAccommodationCard({super.key, required this.accommodation, required this.roomListPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => roomListPage(),  // Navigate to RoomList
            ),
          );
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),  // Slightly rounded corners
          ),
          clipBehavior: Clip.antiAlias,  // Ensure the rounded corners apply to the image
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the accommodation image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  accommodation.thumbnailImage ?? '',  // Fallback if image is null
                  width: double.infinity,
                  fit: BoxFit.cover,  // Cover the entire container
                ),
              ),
              
              // Accommodation name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  accommodation.name ?? 'No name available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ) ?? const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SimplePropertyAccommodationCard extends StatelessWidget {
  final dynamic accommodation;  // Accepts a generalized accommodation type
  final dynamic imager;
  final Widget Function() roomListPage;

  const SimplePropertyAccommodationCard({super.key, required this.accommodation, required this.roomListPage, this.imager});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => roomListPage(),  // Navigate to RoomList
            ),
          );
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),  // Slightly rounded corners
          ),
          clipBehavior: Clip.antiAlias,  // Ensure the rounded corners apply to the image
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the accommodation image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imager.mediaUrl ?? '',  // Fallback if image is null
                  width: double.infinity,
                  fit: BoxFit.cover,  // Cover the entire container
                ),
              ),
              
              // Accommodation name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  accommodation.name ?? 'No name available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ) ?? const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}