import 'package:flutter/material.dart';
import 'package:kao_app/models/motel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../../services/real_time_update_service.dart';
import '../../widgets/cards/motel_card.dart';
import '../../widgets/persistent_drawer.dart';
import 'bookings_page.dart';
import 'motel_list_view_page.dart';
import 'search_page.dart';

class MotelListPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const MotelListPage({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  State<MotelListPage> createState() => _MotelListPageState();
}

class _MotelListPageState extends State<MotelListPage> {
  final ApiService apiService = ApiService();
  final RealTimeUpdateService _realTimeUpdateService = RealTimeUpdateService(); 
  String? userId;
  String? userName;
  String? userEmail;
  bool isLoggedIn = false;
  List<Motel> motels = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchMotels();

    // Set the onDataUpdated callback
    _realTimeUpdateService.onDataUpdated = (hotels, motels, lodges, hostels, properties) {
      fetchMotels(); // Call fetchMotels to refresh the hotel list
    };

    // Start polling for real-time updates
    _realTimeUpdateService.startPolling();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      userName = prefs.getString('name');
      userEmail = prefs.getString('email');
      isLoggedIn = userName != null; // Set isLoggedIn based on presence of user data
    });
  }

  void fetchMotels() async {
    try {
      List<Motel> fetchedMotels = await apiService.fetchMotels();
      setState(() {
        motels = fetchedMotels;
      });
    } catch (error) {
      // print('Failed to fetch hotels: $error');
    }
  }

  @override
  void dispose() {
    _realTimeUpdateService.stopPolling();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to HotelListViewPage but pass along the user data and login status
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MotelListViewPage(
            isDarkMode: widget.isDarkMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index; // Update selected index when an item is tapped
      });
    }
  }

  // Define your page views here
  List<Widget> _pageViews() {
    return [
      ListView.builder(
        itemCount: motels.length,
        itemBuilder: (context, index) {
          return MotelCard(motel: motels[index]);
        },
      ),
      BookingsPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
      SearchPage(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Motels'),
      ),
      drawer: PersistentDrawer(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        onThemeChanged: widget.onThemeChanged,
        isLoggedIn: isLoggedIn,  // Pass login state
      ),
      body: _pageViews()[_selectedIndex], // Show the page according to the selected index
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
        onTap: _onItemTapped,  // Call _onItemTapped when a navigation item is tapped
      ),
    );
  }
}