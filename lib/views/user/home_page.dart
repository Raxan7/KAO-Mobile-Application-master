import 'dart:async'; // Import for Timer

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for storing/retrieving user credentials
import '../../widgets/persistent_drawer.dart'; // Import the Persistent Drawer
import 'dashboard_sideway_slide_views/accomodation_sideway_slider.dart';
import 'bookings_page.dart';
import 'search_page.dart'; // Import the HotelCard widget
import '../login_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode; // Add a field for the current theme state
  final Function(bool) onThemeChanged; // Add a field for the theme change callback

  const HomePage({super.key, required this.isDarkMode, required this.onThemeChanged}); // Constructor to accept parameters

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;
  String? userName;
  String? userEmail;
  bool isLoggedIn = false; // Track user login state

  int _selectedIndex = 0; // Track the selected index of bottom navigation
  late List<Widget> _pages; // PageController to control the PageView

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status
    _loadUserData(); // Load user data when the page initializes

    // Initialize pages with the current theme state and callback
    _pages = [
      const AccomodationSidewaySlider(),
      BookingsPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
      SearchPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
    ];
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      userName = prefs.getString('name'); // Load user name, may be null
      userEmail = prefs.getString('email'); // Load user email, may be null
      isLoggedIn = userName != null; // Set login state based on user name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      drawer: PersistentDrawer(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        onThemeChanged: widget.onThemeChanged,
        isLoggedIn: isLoggedIn,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
