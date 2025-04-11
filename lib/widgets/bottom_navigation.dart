import 'package:flutter/material.dart';
import '../views/user/home_page.dart';
import '../views/user/bookings_page.dart';
import '../views/user/search_page.dart';
import '../views/user/settings_page.dart';
import '../views/user/user_profile.dart';

class BottomNavigation extends StatefulWidget {
  final Function(bool) onThemeChanged; // Callback to toggle theme
  final bool isDarkMode; // Current theme state

  const BottomNavigation({super.key, required this.onThemeChanged, required this.isDarkMode}); // Pass the callback and current theme state

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Explore Hotels',   // Title for Home Page
    'Your Bookings',    // Title for Bookings Page
    'Search Hotels',    // Title for Search Page
  ];

  late List<Widget> _pages; // Initialize empty pages list

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged), // Home Page
      BookingsPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged), // Bookings Page
      SearchPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged), // Search Page
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index for bottom navigation
    });
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),  // Change title dynamically based on the selected tab
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                "User Name",
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black), // Text color based on theme
              ),
              accountEmail: Text(
                "user@example.com",
                style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54), // Text color based on theme
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text("U", style: TextStyle(fontSize: 40.0)),
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF1A237E) : Colors.blue, // Dark blue for dark mode, blue for light mode
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                _navigateTo(const UserProfile());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                _navigateTo(SettingsPage(onThemeChanged: widget.onThemeChanged, isDarkMode: widget.isDarkMode)); // Pass the current theme state
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Display selected page from bottom navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF0D47A1) : Colors.blueAccent, // Change background color for light and dark mode
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Background is handled by the Container
          elevation: 20, // Higher elevation for prominence
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: _onItemTapped, // Change tab on tap
        ),
      ),
    );
  }
}
