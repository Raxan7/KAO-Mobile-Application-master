import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../widgets/dalali/dalali_navigation_drawer.dart';
import 'edit_property_page.dart';
import 'property_detail_page.dart';

class PropertyListPage extends StatefulWidget {
  final String userId;

  const PropertyListPage({super.key, required this.userId});

  @override
  _PropertyListPageState createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late Future<List<Property>> _properties;
  bool isDarkMode = false; // Track dark mode state
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _properties = _apiService.fetchProperties(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Listings')),
      drawer: DalaliNavigationDrawer(
        onThemeChanged: (newIsDarkMode) {
          setState(() {
            isDarkMode = newIsDarkMode;
          });
        },
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      body: FutureBuilder<List<Property>>(
        future: _properties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No properties found'));
          } else {
            final properties = snapshot.data!;
            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailPage(property: property),
                        ),
                      );
                    },
                    child: PropertyCard(
                      property: property,
                      onPropertyUpdated: (updatedProperty) {
                        setState(() {
                          final index = properties.indexWhere(
                              (p) => p.id == updatedProperty.id);
                          if (index != -1) {
                            properties[index] = updatedProperty;
                          }
                        });
                      },
                      onPropertyDeleted: () {
                        setState(() {                          _properties = _apiService.fetchProperties(
                            widget.userId.toString());
                        });
                      },
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

class PropertyCard extends StatefulWidget {
  final Property property;
  final Function(Property) onPropertyUpdated;
  final VoidCallback onPropertyDeleted;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onPropertyUpdated,
    required this.onPropertyDeleted,
  });

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentImageIndex = 0;
  late final List<String> _mediaUrls;
  late final bool _hasMultipleImages;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _mediaUrls = widget.property.media.map((media) => media.mediaUrl).toList();
    _hasMultipleImages = _mediaUrls.length > 1;

    if (_hasMultipleImages) {
      _startImageRotation();
    }
  }

  void _startImageRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _mediaUrls.length;
        });
        _startImageRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Property image or placeholder
          widget.property.media.isNotEmpty
              ? Image.network(
                  _mediaUrls[_currentImageIndex],
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 80)),
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tsh ${widget.property.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bed, color: Colors.blue, size: 20),
                    const SizedBox(width: 4),
                    // Text('${widget.property.numberOfRooms} Rooms'),
                    // const SizedBox(width: 16),
                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Text(widget.property.location),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Status: ${widget.property.status}',
                  style: TextStyle(
                    color: widget.property.status == 'For Sale'
                        ? Colors.blueAccent
                        : widget.property.status == 'For Rent'
                            ? Colors.orangeAccent
                            : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // Edit and Delete action buttons
                OverflowBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final updatedProperty = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditPropertyPage(property: widget.property),
                          ),
                        );

                        if (updatedProperty != null &&
                            updatedProperty is Property) {
                          widget.onPropertyUpdated(updatedProperty);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Property'),
                            content: const Text(
                                'Are you sure you want to delete this property?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () =>
                                    Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () =>
                                    Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            final result = await _apiService.deleteProperty(
                                widget.property.id.toString());
                            if (result['status'] == 'success') {
                              widget.onPropertyDeleted();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Property deleted successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(result['message'] ??
                                        'Failed to delete property')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
