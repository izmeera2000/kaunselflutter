Button , show alert


Function of sending push notification
in PHP
```php
  // admin > functions > chat.php
  

if (isset($_POST['push_notification_topic'])) {

    $topic = "katasemangat";

  

    $title = "Kata-kata Untuk Hari Ini";

  

    $body = $_POST['body'];

    try {

        $result = sendFcmNotificationTopic($topic, $title, $body);

  

        http_response_code(200);

        echo json_encode([

            'success' => true,

            'message' => 'Notification sent successfully.',

            'data' => $result

        ]);

    } catch (Exception $e) {

        http_response_code(500);

        echo json_encode([

            'success' => false,

            'message' => 'Error sending notification.',

            'error' => $e->getMessage()

        ]);

    }

  

    die();

}
```

the fucntion in PHP

```php
  
  
//server.php
function sendFcmNotificationTopic(string $topic, string $title, string $body)

{

    try {

        $serviceAccountData = [

            "type" => $_ENV['site1_type'],

            "project_id" => $_ENV['site1_project_id'],

            "private_key_id" => $_ENV['site1_private_key_id'],

            "private_key" => str_replace('\\n', "\n", $_ENV['site1_private_key']),

            "client_email" => $_ENV['site1_client_email'],

            "client_id" => $_ENV['site1_client_id'],

            "auth_uri" => $_ENV['site1_auth_uri'],

            "token_uri" => $_ENV['site1_token_uri'],

            "auth_provider_x509_cert_url" => $_ENV['site1_auth_provider_x509_cert_url'],

            "client_x509_cert_url" => $_ENV['site1_client_x509_cert_url']

        ];

  

        $scopes = ['https://www.googleapis.com/auth/cloud-platform'];

        $credentials = new ServiceAccountCredentials($scopes, $serviceAccountData);

        $authToken = $credentials->fetchAuthToken();

  

        if (!isset($authToken['access_token'])) {

            throw new Exception("Failed to retrieve access token.");

        }

  

        $accessToken = $authToken['access_token'];

        $projectId = $serviceAccountData['project_id'];

        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

  

        $message = [

            "message" => [

                "topic" => $topic,

                "notification" => [

                    "title" => $title,

                    "body" => $body

                ]

            ]

        ];

  

        $client = new Client();

        $response = $client->post($url, [

            'headers' => [

                'Authorization' => "Bearer {$accessToken}",

                'Content-Type' => 'application/json',

            ],

            'json' => $message

        ]);

  

        return [

            'status' => $response->getStatusCode(),

            'response' => json_decode($response->getBody(), true),

        ];

  

    } catch (\GuzzleHttp\Exception\RequestException $e) {

        // Handle network or API errors from Guzzle

        return [

            'status' => 500,

            'error' => 'HTTP request failed',

            'message' => $e->getMessage(),

            'response' => $e->hasResponse() ? (string) $e->getResponse()->getBody() : null,

        ];

    } catch (\Exception $e) {

        // Handle other PHP errors

        return [

            'status' => 500,

            'error' => 'Unexpected error',

            'message' => $e->getMessage()

        ];

    }

}
```



Triggrer by the dart function in notifications.dart
```dart
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
```

sending http post to {URL/get_chatlist} with the data push_notification_topic so it triggers the isset $_POST['push_notification_topic]