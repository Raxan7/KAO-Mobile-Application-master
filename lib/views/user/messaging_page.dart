import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MessagingPage extends StatefulWidget {
  final int propertyId; // ID of the property
  final int dalaliId; // ID of the dalali
  final String propertyName; // Name of the property
  final String propertyImage; // URL of the property image
  final String initialMessage; // Initial message to send

  const MessagingPage({
    super.key,
    required this.propertyId,
    required this.dalaliId,
    required this.propertyName,
    required this.propertyImage,
    required this.initialMessage,
  });

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  int? _currentUserId; // Replace with the current user ID
  bool _isDisposed = false; // Track if the widget is disposed

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      _refreshMessages(); // Load initial messages
      _startMessageRefresh();
      _sendInitialMessage(); // Send the initial message with the property image
    });
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('userId');
      if (!_isDisposed) {
        setState(() {
          _currentUserId = userIdString != null ? int.tryParse(userIdString) : null;
        });
      }
    } catch (e) {
      print('Failed to load user ID: $e');
    }
  }

  void _startMessageRefresh() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        _refreshMessages();
        _startMessageRefresh();
      }
    });
  }

  void _refreshMessages() async {
    if (_currentUserId == null) return; // Avoid API call if userId is not yet loaded
    try {
      List<Map<String, dynamic>> messages = await ApiService.fetchMessages(
        widget.propertyId,
        _currentUserId!,
        widget.dalaliId,
      );
      if (!_isDisposed) {
        setState(() {
          _messages = messages;
        });
      }
    } catch (e) {
      print('Failed to fetch messages: $e');
    }
  }

  void _sendInitialMessage() async {
    if (_currentUserId == null) return; // Avoid sending message if userId is not yet loaded
    try {
      await ApiService.sendMessageForUser(
        senderId: _currentUserId!,
        receiverId: widget.dalaliId,
        propertyId: widget.propertyId,
        message: widget.initialMessage,
        messageType: 'text',
        attachmentUrl: widget.propertyImage,
      );
      _refreshMessages();
    } catch (e) {
      print('Failed to send initial message: $e');
    }
  }

  void _sendMessage({String? attachmentUrl, String messageType = 'text'}) async {
    if (_currentUserId == null) return; // Avoid sending message if userId is not yet loaded
    if (_messageController.text.isNotEmpty || attachmentUrl != null) {
      String messageText = _messageController.text;
      _messageController.clear();

      try {
        await ApiService.sendMessageForUser(
          senderId: _currentUserId!,
          receiverId: widget.dalaliId,
          propertyId: widget.propertyId,
          message: messageText,
          messageType: messageType,
          attachmentUrl: attachmentUrl,
        );
        if (!_isDisposed) {
          _refreshMessages();
        }
      } catch (e) {
        print('Failed to send message: $e');
      }
    }
  }

  void _removeReaction(int messageId) async {
    try {
      await ApiService.removeReactionFromMessage(messageId);
      _refreshMessages(); // Refresh the messages to reflect the removed reaction
      Navigator.pop(context);
    } catch (e) {
      print('Failed to remove reaction: $e');
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
      print('Failed to react to message: $e');
    }
    Navigator.pop(context);
  }

  String _formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp).add(const Duration(hours: 8));
    return DateFormat('HH:mm').format(dateTime);
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

  @override
  void dispose() {
    _isDisposed = true;
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wait until _currentUserId is loaded before building UI
    if (_currentUserId == null) {
      return const Center(child: CircularProgressIndicator()); // Show a loading indicator
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Enquire about ${widget.propertyName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSender = message['sender_id'] == _currentUserId;

                return GestureDetector(
                  onLongPress: () =>
                      _showReactionOptions(message['message_id'], message['sender_id']),
                  child: Align(
                    alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
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
                                    color: isSender
                                        ? Colors.white
                                        : Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message['created_at']),
                                style: TextStyle(
                                  color: isSender
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (message['reactions'] != null &&
                            message['reactions'] is List)
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Wrap(
                              spacing: 4.0,
                              children: (message['reactions'] as List)
                                  .map<Widget>((reactionData) {
                                String reactionEmoji = _getReactionEmoji(
                                    reactionData['reaction_type']);
                                return GestureDetector(
                                  onLongPress: () => _showReactionOptions(
                                      message["message_id"], message['sender_id']),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSender
                                          ? Colors.teal[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      reactionEmoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
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