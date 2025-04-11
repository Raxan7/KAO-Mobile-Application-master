import 'package:flutter/material.dart';
import 'package:kao_app/models/user_property.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:kao_app/views/user/property_detail.dart';

class Gallery extends StatefulWidget {
  final String userId;
  const Gallery({super.key, required this.userId});

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late Future<List<Map<String, dynamic>>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _fetchPropertiesWithImages();
  }

  Future<List<Map<String, dynamic>>> _fetchPropertiesWithImages() async {
    try {
      final allProperties = await ApiService().fetchPropertiesForUser(userId: widget.userId);

      final groupedProperties = <String, List<UserProperty>>{};
      for (final property in allProperties) {
        groupedProperties.putIfAbsent(property.propertyId, () => []).add(property);
      }

      return groupedProperties.entries.map((entry) {
        final properties = entry.value;
        final firstProperty = properties.first;
        return {
          'property': firstProperty,
          'images': properties.map((p) => p.propertyImage).toList(),
          'status': firstProperty.status,
        };
      }).toList();
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gallery")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No properties found."));
          }

          final properties = snapshot.data!;
          int rentCount = properties.where((p) => p['status'] == 'For Rent').length;
          int saleCount = properties.where((p) => p['status'] == 'For Sale').length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("For Rent: $rentCount | For Sale: $saleCount", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    final imageUrl = property['images'].isNotEmpty
                        ? property['images'][0]
                        : 'https://placeimg.com/640/480/nature';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetail(
                              propertyId: int.parse(property['property'].propertyId), // Pass propertyId
                            ),
                          ),
                        );
                      },
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    );
                  },

                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImageDialog(List<String> images) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(images[index], fit: BoxFit.cover);
              },
            ),
          ),
        );
      },
    );
  }
}
