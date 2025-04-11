import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'messaging_page.dart';
import 'package:intl/intl.dart'; // To format price with commas

class PropertyDetail extends StatefulWidget {
  final int propertyId;

  const PropertyDetail({super.key, required this.propertyId});

  @override
  _PropertyDetailState createState() => _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> {
  String? userId;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    print(userId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Detail'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.fetchPropertyDetailForUser(widget.propertyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final property = snapshot.data!;
            final imageUrl = (property['property_image'][0]).toString();
            final title = property['title'] ?? 'No Title Available';
            final description =
                property['description'] ?? 'No Description Available';
            final price =
                double.tryParse(property['price']?.toString() ?? '0.0') ?? 0.0;
            final formattedPrice = NumberFormat('#,###').format(price);
            final status = property['status'] ?? 'N/A';
            final location = property['location'] ?? 'No Location Specified';
            final dalaliId = property['user_id'] ?? 0;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/placeholder.png',
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Price
                    Text(
                      'Price: Tsh $formattedPrice',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Property Details
                    const Text(
                      'Property Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Status: $status'),
                    const SizedBox(height: 8),
                    Text('Location: $location'),
                    const SizedBox(height: 20),

                    // Features
                    const Text(
                      'Description & Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(description),
                    const SizedBox(height: 20),

                    // Custom Message Input with Send Icon
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              labelText: 'Write your message...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            if (_messageController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please write a message'),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagingPage(
                                  propertyId: widget.propertyId,
                                  dalaliId: dalaliId,
                                  propertyName: title,
                                  propertyImage: imageUrl,
                                  initialMessage: _messageController.text,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.send),
                          color: Colors.teal,
                          iconSize: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User not logged in'),
                                  ),
                                );
                                return;
                              }
                              final response =
                                  await ApiService.createNotification(
                                int.tryParse(userId!)!,
                                dalaliId,
                                widget.propertyId,
                              );
                              if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(response['message'])),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error: ${response['message']}'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.apartment),
                            label: const Text('Request Property'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 76, 175, 80),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
