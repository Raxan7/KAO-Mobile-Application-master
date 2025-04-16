import 'package:flutter/material.dart';
import '../../models/space.dart';
import '../../utils/constants.dart';

class SpaceDetailPage extends StatelessWidget {
  final Space space;

  const SpaceDetailPage({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(space.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3, // Adjust height dynamically
              child: PageView.builder(
                itemCount: space.media.length,
                itemBuilder: (context, index) {
                  final media = space.media[index];
                  return Image.network(
                    '$spaceImage/${media.mediaUrl}',
                    fit: BoxFit.cover,
                    width: double.infinity, // Ensure the image spans the full width
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Subcategory
                  Row(
                    children: [
                      Chip(label: Text(space.categoryName)),
                      const SizedBox(width: 8),
                      Chip(label: Text(space.subcategoryName)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    space.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Location
                  if (space.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(space.location!),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    space.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Contact Information
                  if (space.contactInfo != null) ...[
                    const Text(
                      'Contact Information',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(space.contactInfo!),
                    const SizedBox(height: 16),
                  ],

                  // Website
                  if (space.websiteUrl != null) ...[
                    const Text(
                      'Website',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        // Handle website URL tap
                      },
                      child: Text(
                        space.websiteUrl!,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}