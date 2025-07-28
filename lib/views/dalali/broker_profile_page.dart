import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';

class BrokerProfilePage extends StatelessWidget {
  final String userId;
  final ApiService _apiService = ApiService();

  BrokerProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker Profile'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _apiService.fetchSenderDetails(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No profile information available',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final brokerData = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionTitle('Basic Information'),
                _buildProfileRow('Full Name', brokerData['name']),
                _buildProfileRow('Email', brokerData['email']),
                _buildProfileRow('Phone Number', brokerData['phonenum']),
                const SizedBox(height: 20),

                _buildSectionTitle('Professional Information'),
                _buildProfileRow('Company/Agency Name', brokerData['agency_name'] ?? 'N/A'),
                _buildProfileRow('Position/Title', brokerData['position'] ?? 'N/A'),
                _buildProfileRow('Years of Experience', brokerData['experience_years'] ?? 'N/A'),
                _buildProfileRow('Professional Bio', brokerData['bio'] ?? 'N/A'),
                const SizedBox(height: 20),

                _buildSectionTitle('Licensing & Certifications'),
                _buildProfileRow('License Number', brokerData['license_number'] ?? 'N/A'),
                _buildProfileRow(
                    'Certifications',
                    brokerData['certifications'] != null
                        ? brokerData['certifications'].join(', ')
                        : 'N/A'),
                const SizedBox(height: 20),

                _buildSectionTitle('Location Details'),
                _buildProfileRow('Address', brokerData['address']),
                _buildProfileRow('Operating Regions', brokerData['regions'] ?? 'N/A'),
                const SizedBox(height: 20),

                _buildSectionTitle('Skills & Specializations'),
                _buildProfileRow(
                    'Real Estate Types',
                    brokerData['specializations'] != null
                        ? brokerData['specializations'].join(', ')
                        : 'N/A'),
                _buildProfileRow(
                    'Special Skills',
                    brokerData['skills'] != null ? brokerData['skills'].join(', ') : 'N/A'),
                const SizedBox(height: 20),

                _buildSectionTitle('Portfolio & Achievements'),
                _buildProfileRow('Properties Sold/Managed', brokerData['portfolio'] ?? 'N/A'),
                _buildProfileRow(
                    'Client Testimonials',
                    brokerData['testimonials'] != null
                        ? brokerData['testimonials'].join(', ')
                        : 'N/A'),
                _buildProfileRow(
                    'Awards/Recognitions', brokerData['awards'] ?? 'N/A'),
                const SizedBox(height: 20),

                _buildSectionTitle('Account Settings'),
                // _buildProfileRow('Username', brokerData['username']),
                _buildProfileRow('Notification Preferences',
                    brokerData['notification_preferences'] ?? 'N/A'),
                const SizedBox(height: 20),

                _buildSectionTitle('Optional Features'),
                _buildProfileRow('Language Proficiency', brokerData['languages'] ?? 'N/A'),
                _buildProfileRow('Availability', brokerData['availability'] ?? 'N/A'),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildProfileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
