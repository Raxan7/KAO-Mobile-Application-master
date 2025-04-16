import 'package:flutter/material.dart';
import '../../models/space.dart';
import '../../services/api_service.dart';
import 'space_detail_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/persistent_drawer.dart';
import '../../utils/constants.dart';

class SpacesListPage extends StatefulWidget {
  final String? categoryId;
  final String? subcategoryId;
  final String? userId;
  final String? userName; // Add userName parameter
  final String? userEmail; // Add userEmail parameter
  final bool isLoggedIn; // Add isLoggedIn parameter
  final Function(bool) onThemeChanged; // Add onThemeChanged parameter

  const SpacesListPage({
    super.key,
    this.categoryId,
    this.subcategoryId,
    this.userId,
    this.userName,
    this.userEmail,
    required this.isLoggedIn,
    required this.onThemeChanged,
  });

  @override
  _SpacesListPageState createState() => _SpacesListPageState();
}

class _SpacesListPageState extends State<SpacesListPage> {
  late Future<List<Space>> _spacesFuture;
  int _selectedTabIndex = 0;
  final List<String> _categories = ['Education', 'Creators', 'Technology', 'News'];
  final List<String> _categoryIds = ['1', '2', '3', '4'];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Set initial tab based on categoryId
    _selectedTabIndex = widget.categoryId != null 
        ? _categoryIds.indexOf(widget.categoryId!)
        : 0;
    _loadSpaces();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSpaces() {
    setState(() {
      _spacesFuture = ApiService.fetchSpaces(
        categoryId: _categoryIds[_selectedTabIndex],
        subcategoryId: widget.subcategoryId,
        userId: widget.userId,
      );
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _loadSpaces();
    _showToast('${_categories[index]} clicked');
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Widget _buildSpaceList(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return FutureBuilder<List<Space>>(
      future: _spacesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No ${_categories[_selectedTabIndex]} spaces found'));
        }

        final spaces = snapshot.data!;
        return ListView.builder(
          controller: _scrollController,
          itemCount: spaces.length,
          padding: isDesktop
              ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            final space = spaces[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpaceDetailPage(space: space),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail image
                      if (space.thumbnail != null)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25, // Adjust height dynamically
                          width: double.infinity,
                          child: Image.network(
                            '$spaceImage/${space.thumbnail}',
                            fit: BoxFit.cover,
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
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 8),
                            // Description excerpt
                            Text(
                              space.description.length > 100
                                  ? '${space.description.substring(0, 100)}...'
                                  : space.description,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabButton(String label, int index, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: _selectedTabIndex == index ? const Color(0xFF0D47A1) : Colors.white,
          backgroundColor: _selectedTabIndex == index ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: isDesktop ? 12 : 8,
          ),
        ),
        onPressed: () => _onTabSelected(index),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: !isDesktop ? PersistentDrawer(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        isLoggedIn: widget.isLoggedIn,
        onThemeChanged: widget.onThemeChanged,
      ) : null,
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
            child: Column(
              children: [
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
                        child: _buildSpaceList(context),
                      ),
                      if (isDesktop)
                        Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
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
            ),
          ),
        ],
      ),
    );
  }
}