import 'package:flutter/material.dart';
import 'package:kao_app/widgets/bottom_navigation.dart';
import 'package:kao_app/widgets/persistent_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  final String title;
  final bool showBottomNavigation;
  final bool showDrawer;
  final bool showAppBar;
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    this.showBottomNavigation = true,
    this.showDrawer = true,
    this.showAppBar = true,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  String? userId;
  String? userName;
  String? userEmail;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      userName = prefs.getString('name');
      userEmail = prefs.getString('email');
      isLoggedIn = userId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop && widget.showDrawer) {
      return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(widget.title),
                centerTitle: true,
                backgroundColor: Colors.teal,
              )
            : null,
        body: Row(
          children: [
            SizedBox(
              width: 300, // Fixed width for the drawer
              child: PersistentDrawer(
                userId: userId,
                userName: userName,
                userEmail: userEmail,
                isLoggedIn: isLoggedIn,
                onThemeChanged: widget.onThemeChanged,
              ),
            ),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
        bottomNavigationBar: null,
      );
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title),
              centerTitle: isDesktop,
              backgroundColor: Colors.teal,
            )
          : null,
      drawer: widget.showDrawer
          ? PersistentDrawer(
              userId: userId,
              userName: userName,
              userEmail: userEmail,
              isLoggedIn: isLoggedIn,
              onThemeChanged: widget.onThemeChanged,
            )
          : null,
      body: widget.child,
      bottomNavigationBar: null,
    );
  }
} 