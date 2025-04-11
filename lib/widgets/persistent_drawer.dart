import 'package:flutter/material.dart';
import 'package:kao_app/views/user/bookmarked_property_list.dart';
import 'package:kao_app/views/user/detailed_enquiries_page.dart';
import 'package:kao_app/views/user/property_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/user_preferences.dart';
import '../views/login_page.dart';
import '../views/user/user_profile.dart';  // Import User Profile Page
import '../views/user/settings_page.dart'; // Import Settings Page
import '../views/user/professional_page.dart';

class PersistentDrawer extends StatefulWidget {
  final String? userId;
  final String? userName; // Make userName nullable
  final String? userEmail; // Make userEmail nullable
  final Function(bool) onThemeChanged; // Theme change callback
  final bool isLoggedIn; // Parameter to check if the user is logged in

  const PersistentDrawer({
    super.key,
    this.userName,
    this.userEmail,
    required this.onThemeChanged,
    required this.isLoggedIn, 
    required this.userId, // Add the new parameter
  });

  @override
  _PersistentDrawerState createState() => _PersistentDrawerState();
}

class _PersistentDrawerState extends State<PersistentDrawer> {
  bool _isDarkMode = false;
  List<Map<String, dynamic>> _savedSessions = [];

  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Load theme preference when the drawer is initialized
    _loadSavedSessions();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _loadSavedSessions() async {
    final sessions = await UserPreferences().getUserSessions();
    setState(() {
      _savedSessions = sessions;
    });
  }

  // Function to close the drawer and navigate to a new page
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: widget.isLoggedIn
                ? Text(widget.userName ?? 'Anonymous')
                : const Text('Log in to your account', style: TextStyle(color: Colors.white)), // Prompt user to log in
            accountEmail: widget.isLoggedIn
                ? Text(widget.userEmail ?? 'anonymous user')
                : const Text(''), // Empty email when not logged in
            currentAccountPicture: CircleAvatar(
              backgroundColor: _isDarkMode ? Colors.purple : Colors.white, // Use the retrieved theme preference
              child: Text(widget.isLoggedIn && widget.userName != null && widget.userName!.isNotEmpty
                        ? widget.userName![0] 
                        : 'A', // Default initial
                        style: const TextStyle(fontSize: 40.0),
                    ),
            ),
            decoration: BoxDecoration(
              color: _isDarkMode ? const Color(0xFF1A237E) : Colors.blue, // Set background based on theme
            ),
          ),
          if (!widget.isLoggedIn) // Show login button only if not logged in
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                _navigateTo(context, const LoginPage()); // Close drawer and navigate to login
              },
            ),
          if (widget.isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.apartment),
              title: const Text('Properties'),
              onTap: () {
                _navigateTo(context, 
                PropertyListScreen(
                  userId: widget.userId,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  isLoggedIn: widget.isLoggedIn,
                  onThemeChanged: widget.onThemeChanged,
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.message_rounded),
              title: const Text('My Enquiries'),
              onTap: () {
                final userId = int.parse(widget.userId ?? '0');
                _navigateTo(context, DetailedEnquiriesPage(userId: userId,));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                _navigateTo(context, const UserProfile()); // Close drawer and navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                _navigateTo(context, SettingsPage(onThemeChanged: widget.onThemeChanged, isDarkMode: _isDarkMode)); // Close drawer and navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {
                _navigateTo(context, 
                BookmarkedPropertyList(
                  userId: widget.userId,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  isLoggedIn: widget.isLoggedIn,
                  onThemeChanged: widget.onThemeChanged,
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center),
              title: const Text('Professional Page'),
              onTap: () {
                _navigateTo(context, const ProfessionalPage());
              },
            ),
            const Divider(),
            if (_savedSessions.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Saved Accounts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueAccent, // Added color for better visual appeal
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white, // Background color for dropdown container
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    hint: const Text(
                      "Select Account",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87, // Styling for hint text
                      ),
                    ),
                    value: null, // No initial value, user must select
                    items: [
                      ..._savedSessions.map((session) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: session,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_circle,
                                color: Colors.blueAccent, // Color for icon
                                size: 20, // Increased size for better visibility
                              ),
                              const SizedBox(width: 12),
                              Text(
                                session['name'] ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500, // Slightly bolder text
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                session['email'] ?? 'Unknown Email',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic, // Italic style for distinction
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Add new account button
                      const DropdownMenuItem<Map<String, dynamic>>(
                        value: null, // Special value for this option
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: Colors.green, // Icon for add new account
                              size: 30,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Add New Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (session) async {
                      if (session == null) {
                        // Handle Add New Account action: Log out and navigate to the login screen
                        await AuthService.logout(context); // Log out the current user
                        Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login screen
                        return;
                      }

                      // Handle switching to the selected account
                      await UserPreferences().switchToSession(session);

                      // Redirect based on role
                      String role = session['role'];
                      if (role == 'admin') {
                        Navigator.pushReplacementNamed(context, '/adminDashboard');
                      } else if (role == 'hotelier') {
                        Navigator.pushReplacementNamed(context, '/hotelierDashboard');
                      } else if (role == 'worker') {
                        Navigator.pushReplacementNamed(context, '/workerDashboard');
                      } else if (role == 'dalali') {
                        Navigator.pushReplacementNamed(context, '/dalaliDashboard');
                      } else if (role == 'user') {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    dropdownColor: Colors.white, // Dropdown background color
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueAccent, // Color of dropdown arrow
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await AuthService.logout(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
