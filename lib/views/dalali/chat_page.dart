import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kao_app/utils/constants.dart';

class Message {
  final String content;
  final DateTime timestamp;
  final bool isSentByUser; // true if sent by the user, false if received

  Message({
    required this.content,
    required this.timestamp,
    required this.isSentByUser,
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(
          content: _controller.text,
          timestamp: DateTime.now(),
          isSentByUser: true,
        ));
        _controller.clear();
      });

      // Simulating a response from another user
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(Message(
            content: 'Response to: "${_messages.last.content}"',
            timestamp: DateTime.now(),
            isSentByUser: false,
          ));
        });
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: iconMainColorBlue, // Changed app bar color
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isSentByUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: message.isSentByUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: message.isSentByUser ? iconMainColorBlue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0), // Increased radius for a smoother look
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                offset: Offset(2, 2), // Position of the shadow
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12.0), // Increased padding for better spacing
                          child: Text(
                            message.content,
                            style: const TextStyle(fontSize: 16, color: Colors.black87), // Adjusted text color
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0), // Rounded corners for input
                      ),
                      filled: true,
                      fillColor: Colors.grey[100], // Light background for input field
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Padding inside the text field
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: iconMainColorBlue), // Changed icon color
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
