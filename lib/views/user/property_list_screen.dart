import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kao_app/widgets/cards/property_card.dart';
import '../../models/user_property.dart';
import '../../services/api_service.dart';
import '../../widgets/persistent_drawer.dart';
import 'spaces_list_page.dart';
import 'package:flutter/foundation.dart'; // Add this import for kIsWeb

class PropertyListScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;
  final bool isLoggedIn;
  final Function(bool) onThemeChanged;

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
  int _selectedIndex = 0;
  String _currentPage = 'Home';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _fetchPropertiesWithImages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

      return groupedProperties.entries.map((entry) {
        final properties = entry.value;
        final firstProperty = properties.first;
        return {
          'property': firstProperty,
          'images': properties.map((p) => p.propertyImage).toList(),
        };
      }).toList().reversed.toList();
    } catch (e) {
      print('Error fetching properties: $e');
      throw Exception('Failed to fetch properties: $e');
    }
  }

  void _onItemTapped(int index, String page) {
    setState(() {
      _selectedIndex = index;
      _currentPage = page;
    });

    if (index == 0) {
      _showToast('$page clicked');
    } else {
      final categoryId = index.toString();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpacesListPage(
            categoryId: categoryId,
            userId: widget.userId,
            userName: widget.userName,
            userEmail: widget.userEmail,
            isLoggedIn: widget.isLoggedIn,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Widget _buildTabButton(String label, int index, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: _selectedIndex == index ? const Color(0xFF0D47A1) : Colors.white,
          backgroundColor: _selectedIndex == index ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: isDesktop ? 12 : 8,
          ),
        ),
        onPressed: () => _onItemTapped(index, label),
        child: Text(
          label,
          style: TextStyle(fontSize: isDesktop ? 16 : 14),
        ),
      ),
    );
  }

  Widget _buildPropertyList(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

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
            controller: _scrollController,
            itemCount: properties.length,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: isDesktop ? 16 : 8,
            ),
            itemBuilder: (context, index) {
              final property = properties[index]['property'] as UserProperty;
              final images = properties[index]['images'] as List<String>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PropertyCard(
                  property: property,
                  images: images,
                  isDesktop: isDesktop,
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No properties found.'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: !kIsWeb && !isDesktop // Ensure drawer is not shown on web
          ? PersistentDrawer(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: widget.userEmail,
              isLoggedIn: widget.isLoggedIn,
              onThemeChanged: widget.onThemeChanged,
            )
          : null,
      body: Row(
        children: [
          if (!kIsWeb && isDesktop) // Ensure drawer is not shown on web
            PersistentDrawer(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: widget.userEmail,
              isLoggedIn: widget.isLoggedIn,
              onThemeChanged: widget.onThemeChanged,
            ),
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/herevar_logo_blue.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'herevar',
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isDesktop)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTabButton('Home', 0, isDesktop),
                            _buildTabButton('Education', 1, isDesktop),
                            _buildTabButton('Creators', 2, isDesktop),
                            _buildTabButton('Technology', 3, isDesktop),
                            _buildTabButton('News', 4, isDesktop),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _selectedIndex == 0
                            ? _buildPropertyList(context)
                            : Container(),
                      ),
                      if (isDesktop)
                        Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              _buildTabButton('Home', 0, isDesktop),
                              const SizedBox(height: 8),
                              _buildTabButton('Education', 1, isDesktop),
                              const SizedBox(height: 8),
                              _buildTabButton('Creators', 2, isDesktop),
                              const SizedBox(height: 8),
                              _buildTabButton('Technology', 3, isDesktop),
                              const SizedBox(height: 8),
                              _buildTabButton('News', 4, isDesktop),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
