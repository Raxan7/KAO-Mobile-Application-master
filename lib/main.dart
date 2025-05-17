import 'package:flutter/material.dart';
import 'package:kao_app/services/real_time_update_service.dart';
import 'package:kao_app/utils/app_theme.dart';
import 'package:kao_app/utils/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
    if (!_dataLoaded) {
      return MaterialApp(
        title: 'Discover & Connect',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/splash_icon.png'),
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Discover & Connect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: _initialRoute ?? AppRoutes.login,
      routes: AppRoutes.getRoutes(_isDarkMode, _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

