import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kao_app/widgets/cards/property_card.dart';
import '../../models/user_property.dart';
import '../../services/api_service.dart';
import '../../widgets/persistent_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      print(e);
      throw Exception('Failed to fetch properties: $e');
    }
  }

  List<Widget> _pages(BuildContext context) => [
        _buildPropertyList(context),
        _buildPlaceholderPage('Education Page'),
        _buildPlaceholderPage('Development Page'),
        _buildPlaceholderPage('Agriculture Page'),
      ];

  Widget _buildPropertyList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _propertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final properties = snapshot.data!;
          
          // Responsive grid layout
          if (MediaQuery.of(context).size.width > 600) {
            // Tablet/Desktop view
            return GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 1200 ? 32 : 16,
                vertical: 16,
              ),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index]['property'] as UserProperty;
                final images = properties[index]['images'] as List<String>;
                return PropertyCard(
                  property: property,
                  images: images,
                  isDesktop: MediaQuery.of(context).size.width > 600,
                );
              },
            );
          } else {
            // Mobile view
            return ListView.builder(
              controller: _scrollController,
              itemCount: properties.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final property = properties[index]['property'] as UserProperty;
                final images = properties[index]['images'] as List<String>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyCard(
                    property: property,
                    images: images,
                    isDesktop: false,
                  ),
                );
              },
            );
          }
        } else {
          return const Center(child: Text('No properties found.'));
        }
      },
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index, String page) {
    setState(() {
      _selectedIndex = index;
      _currentPage = page;
    });
    _showToast('$page clicked');
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        centerTitle: isDesktop,
      ),
      drawer: isDesktop ? null : PersistentDrawer(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        isLoggedIn: widget.isLoggedIn,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Responsive tab bar
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 8,
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton('Home', 0, isDesktop),
                      _buildTabButton('Education', 1, isDesktop),
                      _buildTabButton('Development', 2, isDesktop),
                      _buildTabButton('Agriculture', 3, isDesktop),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 0,
                ),
                child: _pages(context)[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: _selectedIndex == index ? Colors.black : Colors.white,
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
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
      ),
    );
  }
}