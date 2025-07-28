import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userId');
    await prefs.remove('phonenum');
    await prefs.remove('address');
    
    // Close the drawer first
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // Navigate to home screen safely
    // Using pushNamedAndRemoveUntil to clear the navigation stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false, // Remove all previous routes
    );
  }

  // Helper method to get user info if needed in the future
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
      'userId': prefs.getString('userId'),
      'role': prefs.getString('role'),
    };
  }
    
}
