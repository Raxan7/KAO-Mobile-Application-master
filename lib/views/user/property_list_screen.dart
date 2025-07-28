import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kao_app/widgets/cards/property_card.dart';
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
      print('🔍 PROPERTY LIST SCREEN: Fetching properties for user: [1m${widget.userId}[0m');
      final allProperties = await ApiService().fetchPropertiesForUser(userId: widget.userId);
      print('🔍 PROPERTY LIST SCREEN: Fetched ${allProperties.length} properties');
      
      final groupedProperties = <String, List<UserProperty>>{};

      for (final property in allProperties) {
        print('🔍 PROPERTY LIST SCREEN: Processing property ID=${property.propertyId}, mediaType=${property.mediaType}');
        groupedProperties
            .putIfAbsent(property.propertyId, () => [])
            .add(property);
      }
      
      print('🔍 PROPERTY LIST SCREEN: Grouped into ${groupedProperties.length} unique properties');

      final result = groupedProperties.entries.map((entry) {
        final properties = entry.value;
        final firstProperty = properties.first;
        
        // Extract media URLs
        final mediaUrls = properties.map((p) => p.propertyImage).toList();
        print('🔍 PROPERTY LIST SCREEN: Property ID=${firstProperty.propertyId} has ${mediaUrls.length} media items');
        
        // Extract media types if available (default to image for legacy support)
        final mediaTypes = properties.map((p) {
          // Use property.mediaType if available, or default to 'image'
          final String mediaType;
          if (p.mediaType != null && p.mediaType!.isNotEmpty) {
            mediaType = p.mediaType!;
          } else {
            mediaType = 'image'; // Default for legacy support
            print('🔍 PROPERTY LIST SCREEN: No media type for URL=${p.propertyImage}, defaulting to "image"');
          }
          print('🔍 PROPERTY LIST SCREEN: Media item URL=${p.propertyImage}, type=$mediaType');
          return mediaType;
        }).toList();
        
        return {
          'property': firstProperty,
          'images': mediaUrls,
          'mediaTypes': mediaTypes,
        };
      }).toList().reversed.toList();
      
      print('🔍 PROPERTY LIST SCREEN: Returning ${result.length} processed properties');
      return result;
    } catch (e) {
      print('❌ PROPERTY LIST SCREEN ERROR: Error fetching properties: $e');
      print('❌ PROPERTY LIST SCREEN ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
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
    final isSelected = _selectedIndex == index;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : const Color(0xFF0D47A1),
        backgroundColor: isSelected ? const Color(0xFF0D47A1) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 25 : 20),
          side: BorderSide(
            color: const Color(0xFF0D47A1),
            width: isSelected ? 0 : 1,
          ),
        ),
        elevation: isSelected ? 4 : 1,
        shadowColor: Colors.black.withOpacity(0.2),
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
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPropertyList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _propertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
            ),
          );
        } else if (snapshot.hasError) {
          print('❌ PROPERTY LIST ERROR: ${snapshot.error}');
          if (snapshot.error is Exception) {
            print('❌ PROPERTY LIST ERROR: ${(snapshot.error as Exception).toString()}');
          }
          
          // Log stack trace if available
          if (snapshot.error is Error) {
            print('❌ PROPERTY LIST ERROR: Stack trace: ${(snapshot.error as Error).stackTrace}');
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check the debug console for more details',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    print('🔄 PROPERTY LIST: Retrying data fetch...');
                    setState(() {
                      _propertiesFuture = _fetchPropertiesWithImages();
                    });
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error Details'),
                        content: SingleChildScrollView(
                          child: Text(
                            'Error: ${snapshot.error}\n\n'
                            'Type: ${snapshot.error.runtimeType}\n\n'
                            'This information can help developers diagnose the issue.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Error Details'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No properties found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new listings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        final properties = snapshot.data!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            final isTablet = constraints.maxWidth > 600;
            
            if (isDesktop) {
              // Two-column layout for desktop
              return _buildGridLayout(properties, 2, constraints);
            } else if (isTablet) {
              // Two-column layout for tablet in landscape
              return _buildGridLayout(properties, 2, constraints);
            } else {
              // Single column for mobile
              return _buildListLayout(properties, constraints);
            }
          },
        );
      },
    );
  }

  Widget _buildGridLayout(List<Map<String, dynamic>> properties, int crossAxisCount, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75, // Adjusted for better card proportions
        ),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index]['property'] as UserProperty;
          final images = properties[index]['images'] as List<String>;
          final mediaTypes = properties[index]['mediaTypes'] as List<String>;
          return PropertyCard(
            property: property,
            images: images,
            mediaTypes: mediaTypes,
            isDesktop: constraints.maxWidth > 900,
          );
        },
      ),
    );
  }

  Widget _buildListLayout(List<Map<String, dynamic>> properties, BoxConstraints constraints) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: properties.length,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      itemBuilder: (context, index) {
        final property = properties[index]['property'] as UserProperty;
        final images = properties[index]['images'] as List<String>;
        final mediaTypes = properties[index]['mediaTypes'] as List<String>;
        return Center(
          child: PropertyCard(
            property: property,
            images: images,
            mediaTypes: mediaTypes,
            isDesktop: false,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          final isTablet = constraints.maxWidth > 600;
          
          if (isDesktop) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout(isTablet);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar with persistent drawer
        PersistentDrawer(
          userId: widget.userId,
          userName: widget.userName,
          userEmail: widget.userEmail,
          isLoggedIn: widget.isLoggedIn,
          onThemeChanged: widget.onThemeChanged,
        ),
        // Main content area
        Expanded(
          child: Column(
            children: [
              // Header with logo and navigation
              _buildDesktopHeader(),
              // Category tabs
              _buildDesktopCategoryTabs(),
              // Content area
              Expanded(
                child: _selectedIndex == 0 || _selectedIndex == 5
                    ? _buildPropertyList(context)
                    : const Center(
                        child: Text(
                          'Category content coming soon',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isTablet) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/herevar_logo_blue.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'herevar',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 2,
        centerTitle: true,
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
          // Category tabs for mobile
          _buildMobileCategoryTabs(isTablet),
          // Content area
          Expanded(
            child: _selectedIndex == 0 || _selectedIndex == 5
                ? _buildPropertyList(context)
                : const Center(
                    child: Text(
                      'Category content coming soon',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/herevar_logo_blue.png',
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 16),
          const Text(
            'herevar Properties',
            style: TextStyle(
              color: Color(0xFF0D47A1),
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Search bar placeholder for future enhancement
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                SizedBox(width: 16),
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Search properties...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCategoryTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: _categories.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildTabButton(entry.value, entry.key, true),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileCategoryTabs(bool isTablet) {
    return Container(
      height: isTablet ? 60 : 50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildTabButton(entry.value, entry.key, false),
            );
          }).toList(),
        ),
      ),
    );
  }
}