import 'package:flutter/material.dart';
import '../views/user/home_page.dart';
import '../views/user/bookings_page.dart';
import '../views/user/search_page.dart';
import '../views/user/settings_page.dart';
import '../views/user/user_profile.dart';

class BottomNavigation extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const BottomNavigation({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Explore Hotels',
    'Your Bookings',
    'Search Hotels',
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
      BookingsPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
      SearchPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final iconSize = isDesktop ? 28.0 : 24.0;
    final titleFontSize = isDesktop ? 24.0 : 20.0;
    final labelFontSize = isDesktop ? 16.0 : 14.0;
    final drawerWidth = isDesktop ? 300.0 : null;
    final avatarSize = isDesktop ? 80.0 : 60.0;
    final listTilePadding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
        : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(fontSize: titleFontSize),
        ),
        centerTitle: isDesktop,
      ),
      drawer: Drawer(
        width: drawerWidth,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                "User Name",
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  fontSize: isDesktop ? 24.0 : 20.0,
                ),
              ),
              accountEmail: Text(
                "user@example.com",
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: isDesktop ? 18.0 : 16.0,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.white,
                child: Text(
                  "U",
                  style: TextStyle(fontSize: avatarSize * 0.5),
                ),
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF1A237E) : Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, size: iconSize),
              title: Text(
                'Profile',
                style: TextStyle(fontSize: labelFontSize),
              ),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(const UserProfile()),
            ),
            ListTile(
              leading: Icon(Icons.settings, size: iconSize),
              title: Text(
                'Settings',
                style: TextStyle(fontSize: labelFontSize),
              ),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(
                SettingsPage(
                  onThemeChanged: widget.onThemeChanged,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, size: iconSize),
              title: Text(
                'Logout',
                style: TextStyle(fontSize: labelFontSize),
              ),
              contentPadding: listTilePadding,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: null, // Hide bottom navigation for now
    );
  }
}
