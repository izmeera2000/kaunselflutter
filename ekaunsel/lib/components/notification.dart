 
import 'package:http/http.dart' as http;
import 'package:ekaunsel/utils/config.dart';
 
 
  Future<void> sendNotificationTopic(String topic, String title, String body) async {
    final url =
        Uri.parse('${Config.base_url}get_chat_list'); // Your PHP endpoint

    final response = await http.post(
      url,
      body: {
        'push_notification_topic': "push_notification_topic",
        'topic': topic,
        'title': title,
        'body': body,
      },
    );
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Notification request sent successfully.');
    } else {
      print('Failed to send notification. Status: ${response.statusCode}');
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

  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    print('Notification sent successfully.');
  } else {
    print('Failed to send notification. Status: ${response.statusCode}');
  }
}
