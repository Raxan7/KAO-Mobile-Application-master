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
// Import the AddSpacePage
import 'package:url_launcher/url_launcher.dart'; // Add this import for launching URLs

// Import SpacesListPage

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

  // Function to launch WhatsApp with feedback message
  Future<void> _sendFeedback() async {
    const phoneNumber = '+255765621493';
    const message = 'Hello, I have feedback about herevar.com: ';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final avatarSize = isDesktop ? 80.0 : 60.0;
    final nameFontSize = isDesktop ? 24.0 : 20.0;
    final emailFontSize = isDesktop ? 18.0 : 16.0;
    final iconSize = isDesktop ? 28.0 : 24.0;
    final listTilePadding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
        : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
    final titleFontSize = isDesktop ? 18.0 : 16.0;

    return Drawer(
      width: isDesktop ? 300 : null,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: widget.isLoggedIn && widget.userName != null && widget.userName!.isNotEmpty
                ? Text(
                    widget.userName!,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    'Welcome, Guest',
                    style: TextStyle(
                      fontSize: nameFontSize,
                      color: Colors.white,
                    ),
                  ),
            accountEmail: widget.isLoggedIn && widget.userEmail != null && widget.userEmail!.isNotEmpty
                ? Text(
                    widget.userEmail!,
                    style: TextStyle(fontSize: emailFontSize),
                  )
                : Text(
                    'Please log in to continue',
                    style: TextStyle(
                      fontSize: emailFontSize,
                      color: Colors.white70,
                    ),
                  ),
            currentAccountPicture: CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: _isDarkMode ? Colors.purple : Colors.white,
              child: Text(
                widget.isLoggedIn && widget.userName != null && widget.userName!.isNotEmpty
                    ? widget.userName![0].toUpperCase()
                    : '?',
                style: TextStyle(fontSize: avatarSize * 0.5),
              ),
            ),
            decoration: BoxDecoration(
              color: _isDarkMode ? const Color(0xFF1A237E) : Colors.blue,
            ),
            margin: EdgeInsets.zero,
          ),
          // Only show login option if user is not properly logged in
          if (!widget.isLoggedIn || widget.userName == null || widget.userName!.isEmpty)
            ListTile(
              leading: Icon(Icons.login, size: iconSize),
              title: Text('Login', style: TextStyle(fontSize: titleFontSize)),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(context, const LoginPage()),
            ),
          // Only show authenticated user options if properly logged in
          if (widget.isLoggedIn && widget.userName != null && widget.userName!.isNotEmpty) ...[
            ListTile(
              leading: Icon(Icons.apartment, size: iconSize),
              title: Text('HOME', style: TextStyle(fontSize: titleFontSize)),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(
                context,
                PropertyListScreen(
                  userId: widget.userId,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  isLoggedIn: widget.isLoggedIn,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message_rounded, size: iconSize),
              title: Text('My Enquiries', style: TextStyle(fontSize: titleFontSize)),
              contentPadding: listTilePadding,
              onTap: () {
                final userId = widget.userId ?? '';
                _navigateTo(context, DetailedEnquiriesPage(userId: userId));
              },
            ),
            ListTile(
              leading: Icon(Icons.person, size: iconSize),
              title: Text('Profile', style: TextStyle(fontSize: titleFontSize)),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(context, const UserProfile()),
            ),
            ListTile(
              leading: Icon(Icons.settings, size: iconSize),
              title: Text('Settings', style: TextStyle(fontSize: titleFontSize)),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(
                context,
                SettingsPage(
                  onThemeChanged: widget.onThemeChanged,
                  isDarkMode: _isDarkMode,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.bookmark, size: iconSize),
              title: Text('Bookmarks', style: TextStyle(fontSize: titleFontSize)),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(
                context,
                BookmarkedPropertyList(
                  userId: widget.userId,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  isLoggedIn: widget.isLoggedIn,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.business_center, size: iconSize),
              title: Text('Professional Page', style: TextStyle(fontSize: titleFontSize)),
              contentPadding: listTilePadding,
              onTap: () => _navigateTo(context, const ProfessionalPage()),
            ),

            // Feedback Section
            const Divider(),
            ListTile(
              leading: Icon(Icons.feedback, size: iconSize, color: Colors.orange),
              title: Text('Send Feedback', style: TextStyle(
                fontSize: titleFontSize,
                color: Colors.orange,
              )),
              contentPadding: listTilePadding,
              onTap: _sendFeedback,
              subtitle: Text('Report issues or suggest improvements', 
                style: TextStyle(fontSize: isDesktop ? 14.0 : 12.0)),
            ),

            const Divider(),
            if (_savedSessions.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
                child: Text(
                  'Saved Accounts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 20.0 : 18.0,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8.0 : 4.0),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 4.0 : 2.0,
                  vertical: isDesktop ? 8.0 : 4.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    hint: Text(
                      "Select Account",
                      style: TextStyle(
                        fontSize: isDesktop ? 18.0 : 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    value: null,
                    items: [
                      ..._savedSessions.map((session) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: session,
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: Colors.blueAccent,
                                size: isDesktop ? 24.0 : 20.0,
                              ),
                              SizedBox(width: isDesktop ? 16.0 : 12.0),
                              Text(
                                session['name'] ?? 'Unknown User',
                                style: TextStyle(
                                  fontSize: isDesktop ? 18.0 : 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: isDesktop ? 16.0 : 12.0),
                              Text(
                                session['email'] ?? 'Unknown Email',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isDesktop ? 16.0 : 14.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const DropdownMenuItem<Map<String, dynamic>>(
                        value: null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: Colors.green,
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
                        await AuthService.logout(context);
                        Navigator.pushReplacementNamed(context, '/login');
                        return;
                      }
                      // Handle account switching by saving the new session
                      await UserPreferences().saveUserDetails(
                        token: session['token'] ?? '',
                        name: session['name'] ?? '',
                        email: session['email'] ?? '',
                        role: session['role'] ?? 'user',
                        userId: session['userId']?.toString() ?? '',
                        phonenum: session['phonenum'] ?? '',
                        address: session['address'] ?? '',
                      );
                      Navigator.pushReplacementNamed(context, '/propertyListScreen');
                    },
                  ),
                ),
              ),
            ],
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, size: iconSize),
              title: Text('Logout', style: TextStyle(fontSize: titleFontSize)),
              onTap: () async {
                try {
                  await AuthService.logout(context);
                } catch (e) {
                  print('Error during logout: $e');
                  // Fallback navigation if the normal logout fails
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}