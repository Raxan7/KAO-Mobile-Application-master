import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SenderInfoPage extends StatelessWidget {
  final String userId;
  final String propertyId;
  final ApiService _apiService = ApiService();

  SenderInfoPage({super.key, required this.userId, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sender Information'),
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
              child: Text('No data found'),
            );
          } else {
            final senderData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${senderData['name']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${senderData['email']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Phone: ${senderData['phonenum']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Address: ${senderData['address']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.teal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Please contact ${senderData['name']} to settle the deal.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
                         