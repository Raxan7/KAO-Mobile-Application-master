import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged; // Callback for theme change
  final bool isDarkMode; // Current theme state

  const SettingsPage({super.key, required this.onThemeChanged, required this.isDarkMode});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkMode = widget.isDarkMode; // Initialize with the passed value
  final bool _darkModeEnabled = false; // Disable dark mode feature for now

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? widget.isDarkMode;
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Load theme preference asynchronously
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: SwitchListTile(
          title: const Text('Dark Mode'),
          value: _isDarkMode,
          onChanged: _darkModeEnabled ? (bool value) {
            setState(() {
              _isDarkMode = value; // Update local state
            });
            widget.onThemeChanged(value); // Notify parent of the theme change
            saveThemePreference(value); // Save preference to SharedPreferences
          } : (bool value) {
            // Show a message if the user tries to toggle
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dark mode feature will be enabled in future versions.'),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }
}
