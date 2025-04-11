import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();
  factory UserPreferences() => _instance;
  UserPreferences._internal();

  static const String _keyToken = 'token';
  static const String _keyName = 'name';
  static const String _keyEmail = 'email';
  static const String _keyRole = 'role';
  static const String _keyUserId = 'userId';
  static const String _keyPhoneNum = 'phonenum';
  static const String _keyAddress = 'address';
  static const String _keyUserSessions = 'userSessions';
  static const String _keyActiveSession = 'activeSession';

  Future<void> saveUserDetails({
    required String token,
    required String name,
    required String email,
    required String role,
    required String userId,
    required String phonenum,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyPhoneNum, phonenum);
    await prefs.setString(_keyAddress, address);

    // Save the user session in the list of sessions
    await saveUserSession(userId, name, email, token, role);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> saveUserSession(String userId, String name, String email,
      String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> userSessions = prefs.getStringList(_keyUserSessions) ?? [];

    // Create a session object
    Map<String, dynamic> session = {
      'userId': userId,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
    };

    // Remove any existing session for the userId to avoid duplicates
    userSessions.removeWhere((s) => jsonDecode(s)['userId'] == userId);
    userSessions
        .add(jsonEncode(session)); // Add the new session as a JSON string

    // Save the updated list
    await prefs.setStringList(_keyUserSessions, userSessions);
  }

  Future<List<Map<String, dynamic>>> getUserSessions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> userSessions = prefs.getStringList(_keyUserSessions) ?? [];
    return userSessions
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  Future<void> switchToSession(Map<String, dynamic> selectedSession) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear current session data (simulate logging out)
    await prefs.remove(_keyToken);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyPhoneNum);
    await prefs.remove(_keyAddress);

    // Save the selected session data as the new current session
    await prefs.setString(_keyToken, selectedSession['token'] ?? '');
    await prefs.setString(_keyName, selectedSession['name'] ?? '');
    await prefs.setString(_keyEmail, selectedSession['email'] ?? '');
    await prefs.setString(_keyRole, selectedSession['role'] ?? '');
    await prefs.setString(_keyUserId, selectedSession['userId'] ?? '');
    await prefs.setString(_keyPhoneNum, selectedSession['phonenum'] ?? '');
    await prefs.setString(_keyAddress, selectedSession['address'] ?? '');

    // Note: Handle navigation in the calling widget, not here.
  }

  Future<Map<String, dynamic>?> getActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? session = prefs.getString(_keyActiveSession);
    return session != null ? jsonDecode(session) : null;
  }
}
