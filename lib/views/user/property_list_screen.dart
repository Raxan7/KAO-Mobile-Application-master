import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kao_app/widgets/cards/property_card.dart';
import '../../models/user_property.dart';
import '../../services/api_service.dart';
import '../../widgets/persistent_drawer.dart'; // Import PersistentDrawer
import 'package:fluttertoast/fluttertoast.dart'; // Import Fluttertoast

class PropertyListScreen extends StatefulWidget {
  final String? userId;
  final String? userName; // Add userName parameter
  final String? userEmail; // Add userEmail parameter
  final bool isLoggedIn; // Add isLoggedIn parameter
  final Function(bool) onThemeChanged; // Add onThemeChanged parameter

  const PropertyListScreen({
    super.key,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.isLoggedIn,
    required this.onThemeChanged,
  });

  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late Future<List<Map<String, dynamic>>> _propertiesFuture;
  int _selectedIndex = 0; // Track selected tab index
  String _currentPage = 'Home'; // Track current page

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _fetchPropertiesWithImages();
  }

  Future<List<Map<String, dynamic>>> _fetchPropertiesWithImages() async {
    try {
      final allProperties = await ApiService().fetchPropertiesForUser();

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

  // Define pages for each tab
  List<Widget> _pages() => [
        _buildPropertyList(),
        _buildPlaceholderPage('Education Page'),
        _buildPlaceholderPage('Development Page'),
        _buildPlaceholderPage('Agriculture Page'),
      ];

  // Build property list page
  Widget _buildPropertyList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
    );
  }

  // Build placeholder page
  Widget _buildPlaceholderPage(String title) {
    return Center(child: Text(title));
  }

  // Handle tab selection
  void _onItemTapped(int index, String page) {
    setState(() {
      _selectedIndex = index;
      _currentPage = page;
    });
  }

  // Show toast message
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
      ),
      drawer: PersistentDrawer(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        isLoggedIn: widget.isLoggedIn,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTabButton('Home', 0),
                _buildTabButton('Education', 1),
                _buildTabButton('Development', 2),
                _buildTabButton('Agriculture', 3),
                // Add more buttons as needed
              ],
            ),
          ),
          Expanded(
            child: _pages()[_selectedIndex], // Display selected page
          ),
        ],
      ),
    );
  }

  // Build tab button
  Widget _buildTabButton(String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: _selectedIndex == index
              ? Colors.black
              : Colors.white, // Text color
          backgroundColor: _selectedIndex == index
              ? Colors.white
              : Colors.black, // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        onPressed: () {
          _onItemTapped(index, label);
          _showToast('$label clicked');
        },
        child: Text(label),
      ),
    );
  }
}
