import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookings_page.dart';
import 'dashboard_sideway_slide_views/accomodation_sideway_slider.dart';
import 'search_page.dart';
import '../../widgets/persistent_drawer.dart';

class HotelListViewPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HotelListViewPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  _HotelListViewPageState createState() => _HotelListViewPageState();
}

class _HotelListViewPageState extends State<HotelListViewPage> {
  String? userId;
  String? userName;
  String? userEmail;
  bool isLoggedIn = false;
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Initialize pages with AccommodationSidewayView as the first page
    _pages = [
      const AccomodationSidewaySlider(), // Set Accommodation Sideway View for "Explore"
      BookingsPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
      SearchPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
    ];
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      userName = prefs.getString('name'); // Load user name, may be null
      userEmail = prefs.getString('email'); // Load user email, may be null
      isLoggedIn = userName != null;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Hotels'),
      ),
      drawer: PersistentDrawer(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        onThemeChanged: widget.onThemeChanged,
        isLoggedIn: isLoggedIn,
      ),
      body: _pages[_selectedIndex], // Show the selected page based on navigation
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
        onTap: _onItemTapped,
      ),
    );
  }
}
