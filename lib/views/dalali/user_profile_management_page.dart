import 'package:flutter/material.dart';
import 'package:kao_app/views/dalali/broker_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../user/profile_picture_page.dart';

class UserProfileManagementPage extends StatefulWidget {
  const UserProfileManagementPage({super.key});

  @override
  State<UserProfileManagementPage> createState() => _UserProfileManagementPageState();
}

class _UserProfileManagementPageState extends State<UserProfileManagementPage> {
  late Future<Map<String, String?>>_userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _getUserInfo();
  }

  Future<Map<String, String?>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
      'userId': prefs.getString("userId"),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile Management'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileInfoSection(),
              const SizedBox(height: 20),
              _buildProfilePictureSection(),
              const SizedBox(height: 20),
              _buildClientReviewSection(),
              const SizedBox(height: 20),
              _buildProfessionalCertificationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection() {
    return _buildCard(
      title: 'Profile Information',
      subtitle: 'Update your contact details, business description, and specialties.',
      icon: Icons.info_outline,
      onTap: () {
        _userInfoFuture.then((userInfo) {
            final userIdString = userInfo['userId'];
            if (userIdString != null) {
              final userId = userIdString;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BrokerProfilePage(userId: userId)),
              );
            }
          });
      }
    );
  }

  Widget _buildProfilePictureSection() {
    return _buildCard(
      title: 'Profile Picture/Logo',
      subtitle: 'Upload a profile picture or company logo for branding purposes.',
      icon: Icons.image,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePicturePage()),
        );
      },
    );
  }

  Widget _buildClientReviewSection() {
    return _buildCard(
      title: 'Client Reviews',
      subtitle: 'View and manage ratings and reviews from clients.',
      icon: Icons.star,
      onTap: () {
        // Navigate to client review management screen (to be implemented)
      },
    );
  }

  Widget _buildProfessionalCertificationSection() {
    return _buildCard(
      title: 'Professional Certification',
      subtitle: 'Show certifications, licenses, or memberships in organizations.',
      icon: Icons.verified,
      onTap: () {
        // Navigate to professional certification management screen (to be implemented)
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.shade100,
          child: Icon(icon, color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: onTap,
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Placeholder for navigation')),
    );
  }
}
