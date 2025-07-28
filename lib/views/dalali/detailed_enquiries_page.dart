import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kao_app/utils/constants.dart';
import 'dart:async';
import '../../services/api_service.dart';
import 'messaging_page.dart';

class DetailedEnquiriesPage extends StatefulWidget {
  final String userId;

  const DetailedEnquiriesPage({super.key, required this.userId});

  @override
  _DetailedEnquiriesPageState createState() => _DetailedEnquiriesPageState();
}

class _DetailedEnquiriesPageState extends State<DetailedEnquiriesPage> {
  List<dynamic>? _enquiries;
  String? _error;
  Timer? _timer;
  bool _initialLoad = true;
  final Map<String, String> _userNamesCache = {};
  final Map<String, String> _profilePicturesCache = {};
  final Map<String, Map<String, dynamic>> _propertyCache = {};
  final ApiService _apiService = ApiService();
  bool _hasUnrepliedMessages = false;

  @override
  void initState() {
    super.initState();
    _fetchAllEnquiriesUser(initialLoad: true);
    _fetchUnrepliedCount();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchAllEnquiriesUser();
      _fetchUnrepliedCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnrepliedCount() async {
    int count = await _apiService.fetchUnrepliedMessageCount(widget.userId);
    if (mounted) {
      setState(() {
        _hasUnrepliedMessages = count > 0;
      });
    }
  }

  Future<void> _fetchAllEnquiriesUser({bool initialLoad = false}) async {
    try {
      if (initialLoad) {
        setState(() {
          _initialLoad = true;
          _error = null;
        });
      }

      final enquiries = await _apiService.fetchAllEnquiriesUser(widget.userId);
      if (mounted) {
        setState(() {
          _enquiries = enquiries;
          _initialLoad = false;
        });

        for (var enquiry in enquiries) {
          var senderId = enquiry['sender_id'];
          var receiverId = enquiry['receiver_id'];
          var otherUserId = (widget.userId == senderId) ? receiverId : senderId;
          var propertyId = enquiry['property_id'];

          if (otherUserId != null && !_userNamesCache.containsKey(otherUserId)) {
            _fetchUserDetails(otherUserId);
          }
          if (propertyId != null && !_propertyCache.containsKey(propertyId)) {
            _fetchPropertyDetails(propertyId);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _fetchUserDetails(int userId) async {
    if (_userNamesCache.containsKey(userId)) return;
    try {
      final String apiUrl = "$baseUrl/api/dalali/get_user_details.php?userId=$userId";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              _userNamesCache[userId.toString()] = responseData['data']['name'] ?? 'Unknown User';
              _profilePicturesCache[userId.toString()] = "$baseUrl/images/users/${responseData['data']['profile_picture'] ?? ''}";
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
  }

  Future<void> _fetchPropertyDetails(int propertyId) async {
    try {
      final propertyDetails = await _apiService.fetchPropertyDetailForUser(propertyId.toString());
      if (mounted) {
        setState(() {
          _propertyCache[propertyId.toString()] = propertyDetails;
        });
      }
    } catch (e) {
      debugPrint("Error fetching property details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Enquiries')),
      body: _initialLoad
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _enquiries == null || _enquiries!.isEmpty
                  ? const Center(child: Text('No enquiries found'))
                  : RefreshIndicator(
                      onRefresh: () async => await _fetchAllEnquiriesUser(),
                      child: ListView.builder(
                        itemCount: _enquiries!.length,
                        itemBuilder: (context, index) {
                          final enquiry = _enquiries![index];
                          var senderId = enquiry['sender_id'];
                          var receiverId = enquiry['receiver_id'];
                          var otherUserId = (widget.userId == senderId) ? receiverId : senderId;
                          final userName = _userNamesCache[otherUserId] ?? 'Unknown User';
                          final profilePicture = _profilePicturesCache[otherUserId] ?? '';
                          final propertyId = enquiry['property_id'];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: profilePicture.isNotEmpty ? NetworkImage(profilePicture) : null,
                                child: profilePicture.isEmpty ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
                              ),
                              title: Text(userName),
                              subtitle: Text(
                                enquiry['message'].length > 50 ? '${enquiry['message'].substring(0, 50)}...' : enquiry['message'],
                              ),
                              trailing: _hasUnrepliedMessages
                                  ? const Icon(Icons.mark_unread_chat_alt, color: Colors.green)
                                  : null,
                              onTap: () {
                                var messageId = enquiry['message_id'];
                                if (messageId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessagingPage(
                                        messageId: messageId,
                                        propertyId: propertyId.toString(),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
