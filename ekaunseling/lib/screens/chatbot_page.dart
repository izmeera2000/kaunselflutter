import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages =
      []; // Holds both sent and received messages

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({
          'message': _controller.text,
          'isSentByUser': 'true', // Sender is the current user
        });
        messages.add({
          'message': 'Got it! How can I assist further?',
          'isSentByUser': 'false', // Receiver is someone else
        });
      });
      _controller.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    messages.add({
      'message': 'Hello , how can i help you?',
      'isSentByUser': 'false', // Receiver is someone else
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            Config.spaceSmall,

            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return MessageBubble(
                    message: messages[index]['message']!,
                    isSentByUser: messages[index]['isSentByUser'] == 'true',
                  );
                },
              ),
            ),

            // Input Area
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
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByUser;

  MessageBubble({required this.message, required this.isSentByUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Align(
        alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isSentByUser ? Config.primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Text(
            message,
            style: TextStyle(
              color: isSentByUser ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
