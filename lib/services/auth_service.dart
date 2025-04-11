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
    
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, '/home'); // Navigate to home after logout
  }

  Future<Map<String, String?>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
    };
  }
    
}
