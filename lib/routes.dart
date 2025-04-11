import 'package:flutter/material.dart';
import 'package:kao_app/views/user/property_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/dalali/dalali_dashboard.dart';
import 'views/dalali/property_management.dart';
import 'views/dalali/add_property_page.dart';
import 'views/dalali/property_list_page.dart';
import 'views/login_page.dart';
import 'views/user/home_page.dart';

// Helper function to retrieve user details from SharedPreferences
Future<Map<String, String?>> getUserDetails() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'userId': prefs.getString('userId'),
    'userName': prefs.getString('name'),
    'userEmail': prefs.getString('email'),
    'userRole': prefs.getString('role'),
    'userPhoneNum': prefs.getString('phoneNum'),
    'userAddress': prefs.getString('address'),
  };
}

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String dalaliDashboard = '/dalaliDashboard';
  static const String propertyList = '/propertyList';
  static const String addProperty = '/addProperty';
  static const String propertyManagement = '/propertyManagement';
  static const String userPropertyListScreen = '/propertyListScreen';
  static const String dalaliProfileInUser = '/dalaliProfileInUser';

  static Map<String, WidgetBuilder> getRoutes(
      bool isDarkMode, Function(bool) onThemeChanged) {
    return {
      home: (context) => HomePage(
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
          ),
      login: (context) => const LoginPage(),
      dalaliDashboard: (context) => FutureBuilder<Map<String, String?>>(
            future: getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text('Error loading user details'));
              } else {
                final userDetails = snapshot.data!;
                final userId = int.tryParse(userDetails['userId'] ?? '0') ?? 0;
                return DalaliDashboard(
                  userId: userId,
                );
              }
            },
          ),
      propertyList: (context) => FutureBuilder<Map<String, String?>>(
            future: getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text('Error loading user details'));
              } else {
                final userDetails = snapshot.data!;
                final userId = int.tryParse(userDetails['userId'] ?? '0') ?? 0;
                return PropertyListPage(
                  userId: userId,
                );
              }
            },
          ),
      addProperty: (context) => const AddPropertyPage(),
      propertyManagement: (context) => const PropertyManagementPage(),
      userPropertyListScreen: (context) => FutureBuilder<Map<String, String?>>(
            future: getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text('Error loading user details'));
              } else {
                final userDetails = snapshot.data!;
                return PropertyListScreen(
                  userId: userDetails['userId'],
                  userName: userDetails['userName'],
                  userEmail: userDetails['userEmail'],
                  isLoggedIn: true,
                  onThemeChanged: onThemeChanged,
                );
              }
            },
          ),
      // dalaliProfileInUser: (context) => ProfileBaseScreen(),
    };
  }
}
