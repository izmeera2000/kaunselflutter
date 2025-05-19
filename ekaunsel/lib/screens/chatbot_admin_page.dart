import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotAdminPage extends StatefulWidget {
  final String? studentName;
  final String? studentImage;
  final String? studentId;

  const ChatbotAdminPage(
      {Key? key, this.studentImage, this.studentId, this.studentName})
      : super(key: key);

  @override
  State<ChatbotAdminPage> createState() => _ChatbotAdminPageState();
}

class _ChatbotAdminPageState extends State<ChatbotAdminPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = []; // List to hold messages
  String? studentId; // User ID for the student
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    studentId = widget.studentId;

    if (studentId != null) {
      _fetchPreviousMessages().then((_) {
        if (messages.isEmpty) {
          setState(() {
            messages.add({
              'message': 'Hello, how can I help you?',
              'sender': 'bot', // Bot's initial message
            });
          });
        }
      });
    }
  }

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Send a message to the server
  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty && studentId != null) {
      // Add the student message to the chat
      setState(() {
        messages.add({
          'message': _controller.text,
          'sender': 'admin', // Sender is the student
        });
        _scrollToBottom();
      });

      // Clear the input field after sending the message
      _controller.clear();

      try {
        final response = await http.post(
          Uri.parse('${Config.base_url}/send_chat'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'user_id': studentId!,
            'message': messages.last['message']!,
            'sender': 'admin', // Ensure sender is student
            'chat_send_admin': 'chat_send_admin',
          },
        );
      } catch (error) {
        print('Error: $error');
      }

      _scrollToBottom();
    }
  }

  // Fetch previous messages from the server
  Future<void> _fetchPreviousMessages() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.base_url}/get_chat'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': studentId!,
          'get_chat_user': 'get_chat_user',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['messages'] != null) {
          setState(() {
            messages.addAll(
              List<Map<String, dynamic>>.from(data['messages'].map((msg) {
                return {
                  'message': msg['message'],
                  'sender':
                      msg['sender'], // Include sender (student, bot, counselor)
                };
              })),
            );
          });
        }
      } else {
        print(
            'Failed to load previous messages. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching previous messages: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Chat',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Chat History
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    // Ensure that values are not null, and fallback to empty strings if they are
                    final message = messageData['message'] ?? '';
                    final sender = messageData['sender'] ?? '';
                    final senderName = messageData['senderName'] ?? sender;

                    return MessageBubble(
                      message: message, // Safe from null
                      sender: sender, // Safe from null
                      senderName: senderName, // Safe from null
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
                  hintText: "Type a message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _sendMessage, // Send message on button click
            ),
          ],
        ),
      ),
            ],
          ),
        ),
      ),
           
    );
  }
}

// Message Bubble Widget
class MessageBubble extends StatelessWidget {
  final String message;
  final String sender;
  final String senderName;

  MessageBubble(
      {required this.message, required this.sender, required this.senderName});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    // Set colors based on sender
    if (sender == 'student') {
      backgroundColor = Colors.blue[300]!;
      textColor = Colors.white;
    } else if (sender == 'bot') {
      backgroundColor = Colors.green[200]!;
      textColor = Colors.black;
    } else {
      backgroundColor = Colors.amber[200]!;
      textColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        crossAxisAlignment: sender == 'admin'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender Name (Above the message)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              senderName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: sender == 'admin' ? Colors.blue[900] : Colors.green[900],
              ),
            ),
          ),
          // Message Bubble
          Align(
            alignment: sender == 'admin'
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
