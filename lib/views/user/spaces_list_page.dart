import 'package:flutter/material.dart';
import 'package:kao_app/routes.dart';
import '../../models/space.dart';
import '../../services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/persistent_drawer.dart';
import '../../widgets/cards/space_card.dart';

class SpacesListPage extends StatefulWidget {
  final String? categoryId;
  final String? subcategoryId;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final bool isLoggedIn;
  final Function(bool) onThemeChanged;

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
  final List<String> _categories = ['Home', 'Education', 'Creators', 'Technology', 'News', 'Discover'];
  final List<String> _categoryIds = ['0', '1', '2', '3', '4', '5'];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add this key
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
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
      _spacesFuture = _apiService.fetchSpaces(
        categoryId: _categoryIds[_selectedTabIndex],
        subcategoryId: widget.subcategoryId,
        userId: widget.userId,
      );
    });
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.userPropertyListScreen);
      return;
    }
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
      key: _scaffoldKey, // Add the key here
      backgroundColor: Colors.white,
      appBar: !isDesktop
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer(); // Use the key to open drawer
                },
              ),
              title: SizedBox(
                width: double.infinity,
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
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            )
          : null,
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