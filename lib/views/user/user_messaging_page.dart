import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserMessagingPage extends StatefulWidget {
  final int messageId; // ID of the message to display
  final int propertyId;

  const UserMessagingPage({
    super.key,
    required this.messageId,
    required this.propertyId,
  });

  @override
  _UserMessagingPageState createState() => _UserMessagingPageState();
}

class _UserMessagingPageState extends State<UserMessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  int _currentUserId = 1;
  bool _isDisposed = false;
  final ScrollController _scrollController = ScrollController();
  final Map<int, String> _userNamesCache = {};

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _scrollController.addListener(_scrollListener);
    _refreshMessages(); // Load initial messages
    _startMessageRefresh();
  }

  void _scrollListener() {
    if (_scrollController.hasClients && _scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        // Top of the list
      } else {
        _scrollToBottom(); // Reached Bottom, then AutoScroll
      }
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('userId'); // Retrieve as a String
    if (!_isDisposed) {
      setState(() {
        _currentUserId =
            userIdString != null ? int.tryParse(userIdString) ?? 1 : 1;
      });
    }
  }

  void _startMessageRefresh() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        _refreshMessages();
        _startMessageRefresh(); // Refresh again
      }
    });
  }

  void _refreshMessages() async {
    try {
      List<Map<String, dynamic>> messages = await ApiService.fetchMessagesById(
          widget.messageId, widget.propertyId);
      if (!_isDisposed) {
        setState(() {
          _messages = messages;

          // Scroll to bottom after the state has been updated and the list is built
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        });
      }
    } catch (e) {
      // print('Failed to fetch messages: $e');
    }
  }

  void _sendMessage(
      {String? attachmentUrl, String messageType = 'text'}) async {
    if (_messageController.text.isNotEmpty || attachmentUrl != null) {
      String messageText = _messageController.text;
      _messageController.clear();

      try {
        await ApiService.replyToUserMessage(
          userId: (_messages[0]['receiver_id']),
          dalaliId: _currentUserId,
          propertyId: widget.propertyId,
          message: messageText,
          messageType: messageType,
          attachmentUrl: attachmentUrl,
        );
        _refreshMessages();
      } catch (e) {
        // print('Failed to send message: $e');
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300), // Adjust duration as needed
      curve: Curves.easeOut, // Adjust curve as needed
    );
  }

  void _removeReaction(int messageId) async {
    try {
      await ApiService.removeReactionFromMessage(messageId);
      _refreshMessages(); // Refresh the messages to reflect the removed reaction
      Navigator.pop(context);
    } catch (e) {
      // print('Failed to remove reaction: $e');
    }
  }

  void _showReactionOptions(int messageId, int senderId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: _currentUserId == senderId ? 160 : 120, // Adjust height if user can delete
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose an action:', style: TextStyle(fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _reactToMessage(messageId, 'like'),
                    child: const Text('👍', style: TextStyle(fontSize: 24)),
                  ),
                  GestureDetector(
                    onTap: () => _reactToMessage(messageId, 'love'),
                    child: const Text('❤️', style: TextStyle(fontSize: 24)),
                  ),
                  GestureDetector(
                    onTap: () => _reactToMessage(messageId, 'laugh'),
                    child: const Text('😂', style: TextStyle(fontSize: 24)),
                  ),
                  GestureDetector(
                    onTap: () => _reactToMessage(messageId, 'sad'),
                    child: const Text('😢', style: TextStyle(fontSize: 24)),
                  ),
                  GestureDetector(
                    onTap: () => _reactToMessage(messageId, 'angry'),
                    child: const Text('😡', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _removeReaction(messageId),
                child: const Text("Remove Reaction"),
              ),
              if (_currentUserId == senderId) ...[ // Show delete button only for sender
                const Divider(), 
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the bottom sheet
                    _confirmDeleteMessage(messageId); // Show delete confirmation
                  },
                  child: const Text("🗑️ Delete Message", style: TextStyle(color: Colors.red)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }


  void _confirmDeleteMessage(int messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Message"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _deleteMessage(messageId);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(int messageId) async {
    try {
      await ApiService.deleteMessage(messageId); // 🔥 Call API to delete message
      _refreshMessages(); // Refresh chat after deletion
    } catch (e) {
      print("Failed to delete message: $e");
    }
  }

  void _reactToMessage(int messageId, String reaction) async {
    try {
      await ApiService.reactToMessage(messageId, reaction);
      _refreshMessages();
    } catch (e) {
      // print('Failed to react to message: $e');
    }
    Navigator.pop(context); // Close the bottom sheet
  }

  String _formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp).add(const Duration(hours: 8));
    return DateFormat('HH:mm').format(dateTime); // Format date and time
  }

  String _getReactionEmoji(String reactionText) {
    switch (reactionText) {
      case 'like':
        return '👍';
      case 'love':
        return '❤️';
      case 'laugh':
        return '😂';
      case 'sad':
        return '😢';
      case 'angry':
        return '😡';
      default:
        return ''; // Return empty if no matching reaction
    }
  }

  // Function to fetch and cache the user name
  Future<String> _getUserName(int userId) async {
    if (userId == _currentUserId) {
      return "Me";
    }
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!; // Return cached name if available
    } else {
      try {
        // Fetch user details from API and get the name
        final userDetails = await ApiService.fetchUserDetails(userId);
        final userName = userDetails['name'] ?? 'Unknown User';
        _userNamesCache[userId] = userName; // Cache the fetched name
        return userName;
      } catch (e) {
        return 'Unknown User';
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed to prevent setState
    _messageController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSender = message['sender_id'] == _currentUserId;

                return FutureBuilder<String>(
                    future: _getUserName(message['sender_id']),
                    builder: (context, snapshot) {
                      final username = snapshot.data ?? 'Loading...';
                      final userInitials = username.isNotEmpty ? username[0].toUpperCase() : '?';
                    
                    return GestureDetector(
                      onLongPress: () => _showReactionOptions(message['message_id'], message['sender_id']), // Show reactions on long press
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Column(
                          crossAxisAlignment:
                              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // Username and avatar
                            Row(
                              mainAxisAlignment:
                                  isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                if (!isSender)
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.teal[200], // Avatar background color
                                    child: Text(
                                      userInitials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (!isSender)
                                  const SizedBox(width: 8), // Spacing between avatar and username
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSender ? Colors.teal : Colors.black87,
                                    fontFamily: 'Roboto', // Customize the font
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4), // Spacing between username and message
                            // Message bubble
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSender ? Colors.teal : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display the attached image if it exists
                                  if (message['attachment_url'] != null && message['attachment_url'].isNotEmpty)
                                    Image.network(
                                      message['attachment_url'],
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                    ),
                                  Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isSender ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4), // Space between message and timestamp
                                  Text(
                                    _formatTimestamp(message['created_at']), // Format and display timestamp
                                    style: TextStyle(
                                      color: isSender ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Reaction display
                            if (message['reactions'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0), // Add spacing above reaction
                                child: GestureDetector(
                                  onLongPress: () => _showReactionOptions(message['message_id'], message['sender_id']),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSender ? Colors.teal[100] : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getReactionEmoji(message['reactions']),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 200, // Limit max height to prevent excessive growth
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null, // Allows multi-line input
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
