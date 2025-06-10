import 'package:ekaunsel/components/retrive_user.dart';
import 'package:ekaunsel/components/user_model.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages =
      []; // List to hold messages with dynamic types
  String? userId; // User ID, which needs to be fetched
  final ScrollController _scrollController = ScrollController();

  // Fetch the user details and set userId
  Future<void> fetchUserDetails() async {
    try {
      // Fetch user details as a UserModel
      UserModel user = await getUserDetails();
      setState(() {
        userId = user.userId; // Ensure user_id exists
      });
    } catch (e) {
      // Handle errors (e.g., user not found)
      debugPrint("Error fetching user details: $e");
    }
  }

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Delay scroll to allow the keyboard and layout to settle
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Send message to the server and get the response
  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty && userId != null) {
      // Add the user message to the chat
      setState(() {
        messages.add({
          'message': _controller.text,
          'sender': 'student', // Sender is the student
        });
        _scrollToBottom();
      });

      // Clear the input field after sending the message
      _controller.clear();

      // Send the message to the server (replace with your actual URL)
      try {
        final response = await http.post(
          Uri.parse(
              '${Config.base_url}/send_chat'), // Replace with your endpoint
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'user_id': userId!,
            'message': messages.last['message']!,
            'sender': 'student', // Ensure sender is student

            'chat_send': 'chat_send',
          },
        );

        if (response.statusCode == 200) {
          // Parse the response
          final data = json.decode(response.body);

          // Check if the response has a bot reply
          if (data['reply'] != null) {
            // Add the bot's reply to the chat
            setState(() {
              messages.add({
                'message': data['reply'], // Bot's reply
                'sender': 'bot', // Ensure sender is student
              });
              _scrollToBottom();
            });
          } else if (data['error'] != null) {
            // Handle errors if any
            debugPrint('Error from server: ${data['error']}');
          }
        } else {
          debugPrint(
              'Failed to get response from server. Status code: ${response.statusCode}');
        }
      } catch (error) {
        debugPrint('Error: $error');
      }
    } else {
      debugPrint('User ID is null or message is empty.');
    }
  }

  // Fetch the last 10 messages from the server
  Future<void> _fetchPreviousMessages() async {
    if (userId == null) {
      debugPrint('User ID is null.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.base_url}/get_chat'), // Replace with your endpoint
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'user_id': userId!,
          'message': messages.isNotEmpty ? messages.last['message']! : '',
          'get_chat_user': 'get_chat_user',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming the server returns a list of messages
        if (data['messages'] != null) {
          setState(() {
            messages.addAll(
              List<Map<String, dynamic>>.from(data['messages'].map((msg) {
                return {
                  'message': msg['message'],
                  'senderName': msg['sender'],
                  'sender':
                      msg['sender'], // Include sender (student, bot, counselor)
                };
              })),
            );
          });
        }
      } else {
        debugPrint(
            'Failed to load previous messages. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching previous messages: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch user details before anything else
    fetchUserDetails().then((_) {
      // Fetch previous messages once the user details are fetched
      if (userId != null) {
        _fetchPreviousMessages().then((_) {
          // Add initial bot message only if no previous messages exist
          if (messages.isEmpty) {
            setState(() {
              messages.add({
                'message': 'Hello, how can I help you?',
                'isSentByUser': 'false', // Receiver is the bot
              });
            });
          }
        });
      }
    });
    _scrollToBottom(); // Scroll to bottom when default message is added
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Chat")),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
              // Input Area
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

  const MessageBubble(
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
        crossAxisAlignment: sender == 'student'
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
                color:
                    sender == 'student' ? Colors.blue[900] : Colors.green[900],
              ),
            ),
          ),
          // Message Bubble
          Align(
            alignment: sender == 'student'
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
