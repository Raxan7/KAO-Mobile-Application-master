import 'package:flutter/material.dart';
import '../../models/property.dart';

class PropertyDetailPage extends StatelessWidget {
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              property.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 10),
            // Text('Size: ${property.size} sqft'),
            // const SizedBox(height: 10),
            // Text('Quantity: ${property.numberOfRooms}'),
            const SizedBox(height: 10),
            Text('Description & Features: ${property.description}'),
            const SizedBox(height: 10),
            Text('Price: Tsh ${property.price.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text('Location: ${property.location}'),
            const SizedBox(height: 10),
            Text('Status: ${property.status}'),
            const SizedBox(height: 10),
            Text('Featured: ${property.featured ? "Yes" : "No"}'),
            const SizedBox(height: 20),
            // Display media (if any)
            if (property.media.isNotEmpty) ...[
              const Text('Media:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: property.media.map((media) {
                  return Column(
                    children: [
                      if (media.mediaType == 'image')
                        Image.network(media.mediaUrl, height: 150),
                      if (media.mediaType == 'video')
                        const Icon(Icons.videocam, size: 50),  // Placeholder for video
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ] else
              const Text('No media available'),
          ],
        ),
      ),
    );
  }
}
