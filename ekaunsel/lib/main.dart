import 'package:ekaunsel/screens/booking_page.dart';
import 'package:ekaunsel/screens/chat_list_page.dart';
import 'package:ekaunsel/screens/chatbot_admin_page.dart';
import 'package:ekaunsel/screens/chatbot_page.dart';
import 'package:ekaunsel/screens/doctor_details.dart';
import 'package:ekaunsel/utils/theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:ekaunsel/screens/login_page.dart';
import 'package:ekaunsel/screens/register_page.dart';
import 'package:ekaunsel/screens/intro_page.dart';
import 'package:ekaunsel/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");
  await initializeFirebaseAppCheck();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  //this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;
      final type = message.data['type']; // 'chat', 'kata', 'general'
      final currentContext = MyApp.navigatorKey.currentContext;

      final currentRoute = ModalRoute.of(currentContext!)?.settings.name;

      if (notification != null && android != null) {
        if (type == 'chat') {
          if (currentRoute != '/chat_user' &&
              currentRoute != '/chat_list' &&
              currentRoute != '/chat_admin') {
            showChatNotification(notification);
          } else {
            debugPrint('Chat notification suppressed on chat page.');
          }
        } else if (type == 'kata') {
          showKataSemangatNotification(notification);
        } else {
          showGeneralNotification(notification);
        }
      }
    });
  }

  void showChatNotification(RemoteNotification notification) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      'New Message',
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          'Chat Messages',
          importance: Importance.defaultImportance,
          priority: Priority.high,
        ),
      ),
    );
  }



  void showKataSemangatNotification(RemoteNotification notification) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      'Kata Semangat',
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'kata_channel',
          'Kata Semangat',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  void showGeneralNotification(RemoteNotification notification) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          importance: Importance.defaultImportance,
          priority: Priority.low,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLoginStatus(context);
    });
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check");
    String? userId = prefs.getString('user_id');
     String? userRole = prefs.getString('role');
    print(userId);
    print(userRole);

    if (userId != null && userRole != null) {
      // User is logged in, navigate to the appropriate page based on their role
      if (userRole == '1') {
        Navigator.of(context).pushReplacementNamed('main2');
        print("admin");
      } else {
        print("user");

        Navigator.of(context).pushReplacementNamed('main');
      }
    } else {
      // User is not logged in, stay on the login page
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //define theme data here
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      title: 'Flutter e-Kaunseling App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.mainTheme,
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => IntroScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        'main': (context) => const MainLayout(),
        'main2': (context) => const Main2Layout(),
        'doctor_details': (context) => const DoctorDetails(),
        'booking_page': (context) => BookingPage(),
        '/chat_list': (context) => ChatListPage(),
        '/chat_user': (context) => ChatbotPage(),
        '/chat_admin': (context) => ChatbotAdminPage(),
      },
    );
  }
}

Future<void> initializeFirebaseAppCheck() async {
  try {
    // Check if the App Check token exists, and fetch a new one if necessary
    String? cachedToken = await getAppCheckToken();

    if (cachedToken == null) {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            AndroidProvider.debug, // Use Play Integrity in production
      );

      String? token = await FirebaseAppCheck.instance.getToken();
      await cacheAppCheckToken(token!);
      debugPrint("App Check Token: $token");
    } else {
      debugPrint("Using cached App Check token");
    }
  } catch (e) {
    debugPrint("Failed to get App Check token: $e");
  }
}

Future<String?> getAppCheckToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('app_check_token');
}

Future<void> cacheAppCheckToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_check_token', token);
}
