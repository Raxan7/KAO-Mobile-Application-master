import 'package:flutter/material.dart';
import '../../models/space.dart';
import '../../services/api_service.dart';
import 'space_detail_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/persistent_drawer.dart';
import '../../utils/constants.dart';
import '../../widgets/cards/space_card.dart';

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

  // In SpacesListPage, replace the Card widget in _buildSpaceList with SpaceCard
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
            return SpaceCard(
              space: space,
              isDesktop: isDesktop,
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