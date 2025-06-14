import 'package:flutter/material.dart';
import 'package:kao_app/views/user/property_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/dalali/dalali_dashboard.dart';
import 'views/dalali/property_management.dart';
import 'views/dalali/add_property_page.dart';
import 'views/dalali/property_list_page.dart';
import 'views/login_page.dart';
import 'views/user/home_page.dart';
import 'views/user/education_page.dart';
import 'views/user/development_page.dart';
import 'views/user/agriculture_page.dart';
import 'views/user/spaces_list_page.dart';
import 'views/user/add_space_page.dart';
import 'widgets/app_scaffold.dart';

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
  static const String education = '/education';
  static const String development = '/development';
  static const String agriculture = '/agriculture';
  static const String spacesList = '/spacesList';
  static const String addSpace = '/addSpace';

  static Map<String, WidgetBuilder> getRoutes(
      bool isDarkMode, Function(bool) onThemeChanged) {
    return {
      home: (context) => HomePage(
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
          ),
      login: (context) => const LoginPage(),
      education: (context) => AppScaffold(
            title: 'Education',
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
            child: EducationPage(
              onThemeChanged: onThemeChanged,
              isDarkMode: isDarkMode,
            ),
          ),
      development: (context) => AppScaffold(
            title: 'Development',
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
            child: DevelopmentPage(
              onThemeChanged: onThemeChanged,
              isDarkMode: isDarkMode,
            ),
          ),
      agriculture: (context) => AppScaffold(
            title: 'Agriculture',
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
            child: AgriculturePage(
              onThemeChanged: onThemeChanged,
              isDarkMode: isDarkMode,
            ),
          ),
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
      spacesList: (context) => FutureBuilder<Map<String, String?>>(
            future: getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text('Error loading user details'));
              } else {
                final userDetails = snapshot.data!;
                return SpacesListPage(
                  userId: userDetails['userId'],
                  userName: userDetails['userName'],
                  userEmail: userDetails['userEmail'],
                  isLoggedIn: true,
                  onThemeChanged: onThemeChanged,
                );
              }
            },
          ),
      addSpace: (context) => const AddSpacePage(),
      // dalaliProfileInUser: (context) => ProfileBaseScreen(),
    };
  }
}
