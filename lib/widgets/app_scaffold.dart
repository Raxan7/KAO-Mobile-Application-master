import 'package:flutter/material.dart';
import 'package:kao_app/utils/responsive_utils.dart';
import 'package:kao_app/widgets/persistent_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  final String title;
  final bool showBottomNavigation;
  final bool showDrawer;
  final bool showAppBar;
  final Function(bool) onThemeChanged;
  final bool isDarkMode;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    this.showBottomNavigation = true,
    this.showDrawer = true,
    this.showAppBar = true,
    required this.onThemeChanged,
    required this.isDarkMode,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
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
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final drawerWidth = isDesktop ? 300.0 : 260.0;

    // AppBar configuration
    final appBar = widget.showAppBar
        ? AppBar(
            title: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context: context,
                  mobile: 18.0,
                  tablet: 20.0,
                  desktop: 22.0,
                ),
              ),
            ),
            centerTitle: isDesktop || isTablet,
            elevation: widget.extendBodyBehindAppBar ? 0 : 1,
            backgroundColor: widget.extendBodyBehindAppBar 
                ? Colors.transparent 
                : null,
            actions: [
              ...?widget.actions,
              IconButton(
                icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
              ),
            ],
          )
        : null;

    // Desktop Layout with side drawer
    if (isDesktop && widget.showDrawer) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: widget.backgroundColor,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        body: Row(
          children: [
            SizedBox(
              width: drawerWidth,
              child: PersistentDrawer(
                userId: userId,
                userName: userName,
                userEmail: userEmail,
                isLoggedIn: isLoggedIn,
                onThemeChanged: widget.onThemeChanged,
              ),
            ),
            Expanded(
              child: PageTransitionSwitcher(
                transitionBuilder: (
                  Widget child,
                  Animation<double> primaryAnimation,
                  Animation<double> secondaryAnimation,
                ) {
                  return FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
                child: widget.child,
              ),
            ),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: widget.bottomNavigationBar,
      );
    }

    // Tablet Layout - with collapsible drawer
    if (isTablet && widget.showDrawer) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: widget.backgroundColor,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawer: Drawer(
          width: drawerWidth,
          child: SafeArea(
            child: PersistentDrawer(
              userId: userId,
              userName: userName,
              userEmail: userEmail,
              isLoggedIn: isLoggedIn,
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        ),
        body: PageTransitionSwitcher(
          transitionBuilder: (
            Widget child,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: widget.child,
        ),
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: widget.bottomNavigationBar,
      );
    }

    // Mobile Layout
    return Scaffold(
      appBar: appBar,
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      drawer: widget.showDrawer
          ? Drawer(
              child: SafeArea(
                child: PersistentDrawer(
                  userId: userId,
                  userName: userName,
                  userEmail: userEmail,
                  isLoggedIn: isLoggedIn,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            )
          : null,
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: widget.child,
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}