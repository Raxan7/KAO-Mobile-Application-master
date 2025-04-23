import 'package:flutter/material.dart';
import '../views/user/home_page.dart';
import '../views/user/add_space_page.dart';
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
    'HOME',
    'Create a Post',
    'Profile',
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
      AddSpacePage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
      UserProfile(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final iconSize = isDesktop ? 28.0 : 24.0;
    final titleFontSize = isDesktop ? 24.0 : 20.0;
    final labelFontSize = isDesktop ? 16.0 : 14.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(fontSize: titleFontSize),
        ),
        centerTitle: isDesktop,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: iconSize),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: iconSize),
            label: 'Create a Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: iconSize),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: labelFontSize,
        unselectedFontSize: labelFontSize,
        onTap: _onItemTapped,
      ),
    );
  }
}
