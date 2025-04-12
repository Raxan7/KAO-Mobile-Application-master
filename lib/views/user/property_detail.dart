import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'messaging_page.dart';
import 'package:intl/intl.dart';

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
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final padding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 100, vertical: 20)
        : const EdgeInsets.all(16.0);

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
            final description = property['description'] ?? 'No Description Available';
            final price = double.tryParse(property['price']?.toString() ?? '0.0') ?? 0.0;
            final formattedPrice = NumberFormat('#,###').format(price);
            final status = property['status'] ?? 'N/A';
            final location = property['location'] ?? 'No Location Specified';
            final dalaliId = property['user_id'] ?? 0;

            return SingleChildScrollView(
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 800 : double.infinity,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            imageUrl,
                            height: isDesktop ? 350 : 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/placeholder.png',
                                    height: isDesktop ? 350 : 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title and Price
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Price: Tsh $formattedPrice',
                      style: TextStyle(
                        fontSize: isDesktop ? 26 : 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Property Details
                    _buildSectionHeader('Property Details', isDesktop),
                    _buildDetailRow('Status:', status, isDesktop),
                    _buildDetailRow('Location:', location, isDesktop),
                    const SizedBox(height: 20),

                    // Features
                    _buildSectionHeader('Description & Features', isDesktop),
                    Text(
                      description,
                      style: TextStyle(fontSize: isDesktop ? 18 : 16),
                    ),
                    const SizedBox(height: 20),

                    // Message Input
                    _buildMessageInput(context, isDesktop, widget.propertyId, 
                        dalaliId, title, imageUrl),
                    const SizedBox(height: 20),

                    // Request Button
                    Center(
                      child: _buildRequestButton(context, isDesktop, userId, dalaliId),
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

  Widget _buildSectionHeader(String text, bool isDesktop) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isDesktop ? 24 : 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: isDesktop ? 18 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDesktop, 
      int propertyId, int dalaliId, String title, String imageUrl) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Write your message...',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isDesktop ? 20 : 16,
              ),
            ),
            maxLines: 3,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.send, size: isDesktop ? 32 : 28),
          color: Colors.teal,
          onPressed: () {
            if (_messageController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please write a message')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessagingPage(
                  propertyId: propertyId,
                  dalaliId: dalaliId,
                  propertyName: title,
                  propertyImage: imageUrl,
                  initialMessage: _messageController.text,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequestButton(BuildContext context, bool isDesktop, 
      String? userId, int dalaliId) {
    return SizedBox(
      width: isDesktop ? 400 : double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not logged in')),
            );
            return;
          }
          final response = await ApiService.createNotification(
            int.tryParse(userId!)!,
            dalaliId,
            widget.propertyId,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
              response['status'] == 'success' 
                ? response['message']
                : 'Error: ${response['message']}'
            )),
          );
        },
        icon: const Icon(Icons.apartment),
        label: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 16 : 12,
          ),
          child: const Text('Request Property'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 76, 175, 80),
          textStyle: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}