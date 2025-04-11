import 'package:flutter/material.dart';

class RoomDetailPage extends StatelessWidget {
  final Map<String, dynamic> roomData; // This will hold room data passed to this page
  final List<String> images; // List of room images
  final List<String> features; // List of room features
  final List<String> facilities; // List of room facilities
  final List<Map<String, dynamic>> reviews; // List of room reviews

  const RoomDetailPage({
    super.key,
    required this.roomData,
    required this.images,
    required this.features,
    required this.facilities,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    // print("RoomData : $roomData");
    // print("");
    // Safely extract room price and rating, providing default values if null
    final double price = roomData['price'] != null ? roomData['price'].toDouble() : 0.0;
    final double rating = roomData['rating'] != null ? roomData['rating'].toDouble() : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(roomData['name'] ?? 'Room Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Add share functionality if needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel for Room Images
              _buildImageCarousel(),
              const SizedBox(height: 20),

              // Room Price and Rating
              Text(
                'Tsh $price per night',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildStarRating(rating),  // Ensure rating is a double
              const SizedBox(height: 20),

              // Features Section
              _buildSectionHeader('Features'),
              _buildChipList(features),
              const SizedBox(height: 20),

              // Facilities Section
              _buildSectionHeader('Facilities'),
              _buildChipList(facilities),
              const SizedBox(height: 20),

              // Guests and Area Information
              _buildGuestsAndArea(),
              const SizedBox(height: 20),

              // Room Description
              _buildSectionHeader('Description'),
              Text(
                roomData['description'] ?? 'No description available',  // Handle null description
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Reviews Section
              _buildSectionHeader('Reviews & Ratings'),
              _buildReviewsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Add booking functionality
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            backgroundColor: Colors.blue, // Customize button color
          ),
          child: const Text('Book Now'),
        ),
      ),
    );
  }

  // Image Carousel for Room Images
  Widget _buildImageCarousel() {
    if (images.isEmpty) {
      return const Center(child: Text("No images available")); // Fallback message
    }
    
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index].startsWith('http')
              ? images[index]
              : 'https://yourwebsite.com/${images[index]}';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/fallback_image.png', // Fallback image
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Star Rating Display
  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (var i = 0; i < 5; i++) {
      stars.add(
        Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: Colors.yellow,
        ),
      );
    }
    return Row(children: stars);
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // Chip List for Features and Facilities
  Widget _buildChipList(List<String> items) {
    return Wrap(
      spacing: 10,
      children: items.map((item) {
        return Chip(
          label: Text(item),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  // Guests and Area Information
  Widget _buildGuestsAndArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Chip(
              label: Text('${roomData['adults'] ?? 0} Adults'),
              backgroundColor: Colors.lightBlueAccent,
            ),
            const SizedBox(width: 10),
            Chip(
              label: Text('${roomData['children'] ?? 0} Children'),
              backgroundColor: Colors.lightGreen,
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Area',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Chip(
          label: Text('${roomData['area'] ?? 'N/A'} sq. ft.'),
          backgroundColor: Colors.grey[300],
        ),
      ],
    );
  }

  // Reviews Section
  Widget _buildReviewsSection() {
    if (reviews.isEmpty) {
      return const Text('No reviews yet.');
    }
    return Column(
      children: reviews.map((review) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                review['profilePicUrl'] ?? 'https://yourwebsite.com/default_avatar.png', // Provide a default URL if null
              ),
              onBackgroundImageError: (_, __) => const Icon(Icons.person), // Fallback in case the image fails
            ),
            title: Text(
              review['userName'] ?? 'Anonymous', // Default to 'Anonymous' if userName is null
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                _buildStarRating((review['rating'] ?? 0).toDouble()), // Handle null rating
                const SizedBox(height: 5),
                Text(
                  review['reviewText'] ?? 'No review text provided.', // Default text if reviewText is null
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

}
