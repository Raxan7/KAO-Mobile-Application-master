import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  // Function to load theme preference
  static Future<bool> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false; // Return false if the key doesn't exist
  }

  // Function to save theme preference
  static Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}
