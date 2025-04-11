import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for storing/retrieving user credentials

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? userName;
  String? userEmail;
  String? userPhoneNum;
  String? userAddress;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page initializes
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name'); // Load user name, may be null
      userEmail = prefs.getString('email'); // Load user email, may be null
      userPhoneNum = prefs.getString('phonenum');
      userAddress = prefs.getString('address');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).primaryColor, // Use primary color
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          userName == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You are not logged in',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the login page
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('Log in to your account'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Profile Picture Section
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://placeimg.com/640/480/people'), // Replace with your image URL
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        'Name: $userName',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(
                        'Email: $userEmail',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(
                        'Phone Number: $userPhoneNum',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        'Address: $userAddress',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}