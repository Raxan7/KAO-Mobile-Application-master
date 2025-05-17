import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kao_app/utils/responsive_utils.dart';
import 'package:kao_app/widgets/cards/property_card_fixed.dart';
import 'package:kao_app/widgets/responsive_grid.dart';
import 'package:kao_app/widgets/shimmer_loading.dart';
import '../../models/user_property.dart';
import '../../services/api_service.dart';
import '../../widgets/persistent_drawer.dart';
import 'spaces_list_page.dart';

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
  final ScrollController _scrollController = ScrollController();
  final List<String> _categories = ['Home', 'Education', 'Creators', 'Technology', 'News', 'Discover'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    });

    if (index == 0) {
      _showToast('$page clicked');
    } else if (index == 5) {
      _showToast('Discover clicked');
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
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _propertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show shimmer loading effect
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: isDesktop ? 16 : 8,
            ),
            child: ResponsiveGrid(
              children: List.generate(
                6,
                (index) => ShimmerLoading(
                  isLoading: true,
                  child: PropertyCardShimmer(isDesktop: isDesktop),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final properties = snapshot.data!;

          if (properties.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No properties found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for new listings',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: isDesktop ? 16 : 8,
            ),
            child: ResponsiveGrid(
              spacing: 16,
              runSpacing: 16,
              children: properties.map((propertyData) {
                final property = propertyData['property'] as UserProperty;
                final images = propertyData['images'] as List<String>;
                
                return PropertyCardFixed(
                  property: property,
                  images: images,
                  isDesktop: isDesktop,
                );
              }).toList(),
            ),
          );
        } else {
          return const Center(child: Text('No properties found.'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveUtils.isDesktop(context);
    
    final categoriesWidget = Column(
      children: [
        if (!isDesktop)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _categories.asMap().entries.map((entry) {
                    return _buildTabButton(entry.value, entry.key, isDesktop);
                  }).toList(),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _selectedIndex == 0 || _selectedIndex == 5
                    ? _buildPropertyList(context)
                    : Container(),
              ),
              if (isDesktop)
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: _categories.asMap().entries.map((entry) {
                      return Column(
                        children: [
                          _buildTabButton(entry.value, entry.key, isDesktop),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: !isDesktop 
        ? AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: Row(
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
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          )
        : null,
      drawer: !isDesktop
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
          if (isDesktop)
            PersistentDrawer(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: widget.userEmail,
              isLoggedIn: widget.isLoggedIn,
              onThemeChanged: widget.onThemeChanged,
            ),
          Expanded(
            child: categoriesWidget,
          ),
        ],
      ),
    );
  }
}