import 'package:ekaunsel/components/date_parse.dart';
import 'package:ekaunsel/screens/chatbot_admin_page.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // List to hold chat data
  List<Map<String, dynamic>> chatList = [];

  // Function to fetch the chat list from the server
  Future<void> fetchChatList() async {
    try {
      final response = await http.post(
        Uri.parse(
            '${Config.base_url}/get_chat_list'), // Replace with your API URL
        body: {
          'get_chat_list': 'get_chat_list', // Post data for fetching chat list
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['users'] != null) {
          setState(() {
            // Convert response data to list of chat items
            chatList = List<Map<String, dynamic>>.from(
              data['users'].map((user) => {
                    'name': user['nama'],
                    'user_id': user['user_id'],
                    'image_url': user['image_url'],
                    'lastMessage': user['message'],
                    'time': timeAgo(user[
                        'created_at']), // Use the timeAgo function to format created_at
                  }),
            );
          });
        } else {
          // Handle case where no chat users are found
          print('No chat users found.');
        }
      } else {
        print('Failed to load chat list');
      }
    } catch (error) {
      print('Error fetching chat list: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChatList(); // Fetch chat list when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: chatList.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : ListView.separated(
              itemCount: chatList.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = chatList[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25, // Optional: Set a custom radius for the avatar
                    backgroundImage: NetworkImage(
                        "${Config.base_url}/assets/img/user/${chat['user_id']}/${chat['image_url']!}"), // Load image from URL
                  ),
                  title: Text(chat['name']!),
                  subtitle: Text(chat['lastMessage']!),
                  trailing: Text(chat['time']!),
                  onTap: () {
                    // Navigate to chat screen with selected user
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatbotAdminPage(
                          studentId: chat['user_id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
