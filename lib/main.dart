import 'package:flutter/material.dart';
import 'package:kao_app/services/real_time_update_service.dart';
import 'package:kao_app/utils/theme_preferences.dart';
import 'package:kao_app/utils/video_player_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://uiowhnicrrnzjkxrxyoj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpb3dobmljcnJuempreHJ4eW9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNzAzNDAsImV4cCI6MjA2ODk0NjM0MH0.fLUV57g0giqE5mc2suhzTrsi_uKDgJ1wWIfR9T9GDqs',
    debug: true,
  );
  
  // Start VideoPlayer initialization but DON'T await it
  // This way it won't block app startup
  VideoPlayerHelper().initializeVideoPlayer();
  
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
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return _dataLoaded
        ? MaterialApp(
            title: 'Discover & Connect',
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
}

