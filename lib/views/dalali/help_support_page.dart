import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpCenterSection(),
            const SizedBox(height: 20),
            _buildCustomerSupportSection(),
            const SizedBox(height: 20),
            _buildTrainingResourcesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCenterSection() {
    return _buildCard(
      title: 'Help Center',
      subtitle: 'Access tutorials, FAQs, and guides on how to use the platform.',
      onTap: () {
        // Navigate to Help Center screen (to be implemented)
      },
    );
  }

  Widget _buildCustomerSupportSection() {
    return _buildCard(
      title: 'Customer Support',
      subtitle: 'Get rich chat and email support for assistance.',
      onTap: () {
        // Navigate to Customer Support screen (to be implemented)
      },
    );
  }

  Widget _buildTrainingResourcesSection() {
    return _buildCard(
      title: 'Training Resources',
      subtitle: 'Find webinars and resources on best practices for selling or renting properties.',
      onTap: () {
        // Navigate to Training Resources screen (to be implemented)
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: onTap,
      ),
    );
  }
}
