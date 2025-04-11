import 'package:flutter/material.dart';

class ProfessionalPage extends StatelessWidget {
  const ProfessionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('phodawson'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'my Portfolio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildMenuItem(Icons.inbox, 'Inbox'),
          _buildMenuItem(Icons.home, 'To wear home'),
          _buildMenuItem(Icons.settings, 'Settings'),
          _buildMenuItem(Icons.person, 'About me'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}