import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SenderInfoPage extends StatelessWidget {
  final int userId;
  final int propertyId;

  const SenderInfoPage({super.key, required this.userId, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sender Information'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.fetchSenderDetails(userId),
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
                'No sender information available',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final senderData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            senderData['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.email, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                senderData['email'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                senderData['phonenum'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  senderData['address'],
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      icon: const Icon(Icons.contact_phone),
                      label: const Text(
                        'Contact Now',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        final phoneNumber = senderData['phonenum'];
                        final Uri phoneUri = Uri(
                          scheme: 'tel',
                          path: phoneNumber,
                        );

                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Unable to open phone dialer'),
                            ),
                          );
                        }
                      },
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
