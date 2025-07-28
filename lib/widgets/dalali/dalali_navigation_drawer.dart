import 'package:flutter/material.dart';
import 'package:kao_app/views/dalali/detailed_enquiries_page.dart';
import 'package:kao_app/views/user/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/user_preferences.dart';
import '../../views/dalali/dalali_dashboard.dart';
import '../../views/dalali/help_support_page.dart';
import '../../views/dalali/notifications_page.dart';
import '../../views/dalali/add_property_page.dart';
import '../../views/dalali/property_list_page.dart';
import '../../views/dalali/security_compliance_page.dart';
import '../../views/dalali/user_profile_management_page.dart';

class DalaliNavigationDrawer extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const DalaliNavigationDrawer({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  _DalaliNavigationDrawerState createState() => _DalaliNavigationDrawerState();
}

class _DalaliNavigationDrawerState extends State<DalaliNavigationDrawer> {
  late Future<Map<String, String?>> _userInfoFuture;
  List<Map<String, dynamic>> _savedSessions = [];

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _getUserInfo();
    _loadSavedSessions();
  }

  Future<Map<String, String?>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
      'userId': prefs.getString("userId"),
    };
  }

  Future<void> _loadSavedSessions() async {
    final sessions = await UserPreferences().getUserSessions();
    setState(() {
      _savedSessions = sessions;
    });
  }

  void _switchToSession(Map<String, dynamic> session) async {
    await UserPreferences().switchToSession(session);

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<Map<String, String?>>(
            future: _userInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(child: Text('Error loading user info')),
                );
              } else {
                final userInfo = snapshot.data!;
                return UserAccountsDrawerHeader(
                  accountName: Text(userInfo['name'] ?? 'User Name'),
                  accountEmail: Text(userInfo['email'] ?? 'user@example.com'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: isDarkMode ? Colors.purple : Colors.white,
                    child: Text(
                      (userInfo['name'] != null && userInfo['name']!.isNotEmpty)
                          ? userInfo['name']![0]
                          : 'L',
                      style: const TextStyle(fontSize: 40.0),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1A237E) : Colors.blue,
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              _userInfoFuture.then((userInfo) {
                final userIdString = userInfo['userId'];
                if (userIdString != null) {
                  final userId = userIdString;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DalaliDashboard(userId: userId),
                    ),
                  );
                } else {
                  // print('Error: userId is null');
                }
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Property Listings'),
            onTap: () {
              _userInfoFuture.then((userInfo) {
                final userIdString = userInfo['userId'];
                if (userIdString != null) {
                  final userId = userIdString;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PropertyListPage(userId: userId)),
                  );
                }
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_business),
            title: const Text('Add New Property'),
            onTap: () {
              _userInfoFuture.then((userInfo) {
                final userId = userInfo['userId'] ?? '0';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPropertyPage(userId: userId),
                  ),
                );
              });
            },
          ),
          ListTile(
            title: const Text('Enquiry'), // New notifications item
            leading: const Icon(Icons.message),
            onTap: () {
              _userInfoFuture.then((userInfo) {
                final userIdString = userInfo['userId'];
                if (userIdString != null) {
                  final userId = userIdString;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailedEnquiriesPage(userId: userId)),
                  );
                }
              });
            }
          ),
          ListTile(
            title: const Text('Notifications'), // New notifications item
            leading: const Icon(Icons.notifications),
            onTap: () {
              _userInfoFuture.then((userInfo) {
                final userIdString = userInfo['userId'];
                if (userIdString != null) {
                  final userId = userIdString;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage(targetUserId: userId)),
                  );
                }
              });
            }
          ),
          // ListTile(
          //   leading: const Icon(Icons.attach_money), // Example icon
          //   title: const Text('Offer Management'),
          //   onTap: () {
          //     _navigateTo(context, const OfferManagementPage());
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.analytics), // Icon for analytics
          //   title: const Text('Analytics & Insight'),
          //   onTap: () {
          //     _navigateTo(context, const AnalyticsInsightPage());
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.monetization_on), // Icon for monetization
          //   title: const Text('Monetization Options'),
          //   onTap: () {
          //     _navigateTo(context, const MonetizationOptionsPage());
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.payment), // Icon for payment and billing
          //   title: const Text('Payment & Billing'),
          //   onTap: () {
          //     _navigateTo(context, const PaymentBillingPage());
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Profile Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileManagementPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              _navigateTo(
                context,
                SettingsPage(
                  onThemeChanged: widget.onThemeChanged,
                  isDarkMode: widget.isDarkMode,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security & Compliance'),
            onTap: () {
              _navigateTo(context, const SecurityCompliancePage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              _navigateTo(context, const HelpSupportPage());
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
                      Navigator.pushReplacementNamed(context, '/propertyListScreen');
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
      ),
    );
  }
}
