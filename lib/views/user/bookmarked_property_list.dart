import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kao_app/widgets/cards/property_card.dart';
import '../../models/user_property.dart';
import '../../services/api_service.dart';
import '../../widgets/persistent_drawer.dart'; // Import PersistentDrawer

class BookmarkedPropertyList extends StatefulWidget {
  final String? userId;
  final String? userName; // Add userName parameter
  final String? userEmail; // Add userEmail parameter
  final bool isLoggedIn; // Add isLoggedIn parameter
  final Function(bool) onThemeChanged; // Add onThemeChanged parameter

  const BookmarkedPropertyList({
    super.key,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.isLoggedIn,
    required this.onThemeChanged,
  });

  @override
  _BookmarkedPropertyListState createState() => _BookmarkedPropertyListState();
}

class _BookmarkedPropertyListState extends State<BookmarkedPropertyList> {
  late Future<List<Map<String, dynamic>>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _fetchPropertiesWithImages();
  }

  Future<List<Map<String, dynamic>>> _fetchPropertiesWithImages() async {
    try {
      final allProperties = await ApiService().fetchBookmarkedPropertiesForUser(userId: widget.userId!);

      final groupedProperties = <String, List<UserProperty>>{};
      for (final property in allProperties) {
        groupedProperties
            .putIfAbsent(property.propertyId, () => [])
            .add(property);
      }

      // Convert map to list and reverse it
      final propertiesList = groupedProperties.entries.map((entry) {
        final properties = entry.value;
        final firstProperty = properties.first;
        return {
          'property': firstProperty,
          'images': properties.map((p) => p.propertyImage).toList(),
        };
      }).toList();

      return propertiesList.reversed.toList(); // Reverse the list
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Properties'),
      ),
      drawer: PersistentDrawer(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        isLoggedIn: widget.isLoggedIn,
        onThemeChanged: widget.onThemeChanged,
      ), // Attach the drawer
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final properties = snapshot.data!;
            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index]['property'] as UserProperty;
                final images = properties[index]['images'] as List<String>;

                return PropertyCard(
                  property: property,
                  images: images,
                );
              },
            );
          } else {
            return const Center(child: Text('No properties found.'));
          }
        },
      ),
    );
  }
}
