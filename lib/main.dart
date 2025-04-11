import 'package:flutter/material.dart';
import 'package:kao_app/services/real_time_update_service.dart';
import 'package:kao_app/utils/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';

void main() {
  RealTimeUpdateService realTimeUpdateService = RealTimeUpdateService();
  realTimeUpdateService.startPolling();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  String? _initialRoute;
  bool _dataLoaded = false; // Track loading state

  // Load theme preference from shared preferences
  Future<void> _loadTheme() async {
    try {
      bool isDarkMode = await ThemePreferences.loadThemePreference();
      setState(() {
        _isDarkMode = isDarkMode;
      });
    } catch (e) {
      // print('Error loading theme: $e');
    }
  }

  // Load user role and set initial route
  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('role');
      // print('Role: $role');

      setState(() {
        _initialRoute = role == 'dalali' ? AppRoutes.dalaliDashboard : AppRoutes.userPropertyListScreen;
        // _initialRoute = role == 'dalali' ? AppRoutes.dalaliDashboard : AppRoutes.dalaliProfileInUser;
      });
    } catch (e) {
      // print('Error loading user role: $e');
    }
  }

  // Load all necessary data for the app to start
  Future<void> _loadData() async {
    await Future.wait([
      _loadTheme(),
      _loadUserRole(),
    ]);

    // Mark as fully loaded
    setState(() {
      _dataLoaded = true;
    });
  }

  // Toggle theme
  void _toggleTheme(bool isDarkMode) async {
    setState(() {
      _isDarkMode = isDarkMode;
    });
    await ThemePreferences.saveThemePreference(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return _dataLoaded
        ? MaterialApp(
            title: 'Hotel Booking App',
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF1A237E),
              scaffoldBackgroundColor: const Color(0xFF0D47A1),
              appBarTheme: const AppBarTheme(
                color: Color(0xFF1A237E),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF0D47A1),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey,
              ),
            ),
            themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: _initialRoute ?? AppRoutes.login,
            routes: AppRoutes.getRoutes(_isDarkMode, _toggleTheme),
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
