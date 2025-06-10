 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ekaunsel/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
 
Future<void> sendNotificationTopic(
    String topic, String title, String body, String sitename) async {
  final url = Uri.parse('${Config.base_url}get_chat_list'); // Your PHP endpoint

  final response = await http.post(
    url,
    body: {
      'push_notification_topic': "push_notification_topic",
      'topic': topic,
      'title': title,
      'body': body,
      'siteName': sitename,
    },
  );
  debugPrint('Response body: ${response.body}');

  if (response.statusCode == 200) {
    debugPrint('Notification request sent successfully.');
  } else {
    debugPrint('Failed to send notification. Status: ${response.statusCode}');
  }
}


Future<void> sendNotificationToFCM(String token, String title, String body) async {
  final url = Uri.parse('${Config.base_url}get_chat_list'); // Your PHP endpoint

  final response = await http.post(
    url,
    body: {
      'push_notification_token': "push_notification_token",
      'token': token,
      'title': title,
      'body': body,
    },
  );

  debugPrint('Response body: ${response.body}');

  if (response.statusCode == 200) {
    debugPrint('Notification sent successfully.');
  } else {
    debugPrint('Failed to send notification. Status: ${response.statusCode}');
  }
}



Future<void> subscribeToTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print('✅ Subscribed to topic: $topic');

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> topics = prefs.getStringList('subscribed_topics') ?? [];

    if (!topics.contains(topic)) {
      topics.add(topic);
      await prefs.setStringList('subscribed_topics', topics);
    }
  } catch (e) {
    print('❌ Failed to subscribe to topic: $e');
  }
}

