import 'package:ekaunsel/screens/booking_page.dart';
import 'package:ekaunsel/screens/doctor_details.dart';
import 'package:ekaunsel/screens/succes_booked.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");
  await initializeFirebaseAppCheck();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settings = InitializationSettings(android: android);
  await flutterLocalNotificationsPlugin.initialize(settings);
// Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Foreground message listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint(
        "Received a message while app is in the foreground: ${message.messageId}");
    if (message.notification != null) {
      debugPrint('Notification Title: ${message.notification!.title}');
      debugPrint('Notification Body: ${message.notification!.body}');

      // Show local notification when a message is received in the foreground
      _showNotification(
        flutterLocalNotificationsPlugin,
        message.notification!,
      );
    }
  });
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
  late final FirebaseMessaging _fcm;

  @override
  void initState() {
    super.initState();
    _fcm = FirebaseMessaging.instance;

    // Request permission (iOS & Android 13+)
    _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Get the token each time the app launches
    _fcm.getToken().then((token) {
      print('FCM Token: $token');
      // TODO: send this token to your backend and associate with the user
    });

    // Handle messages while the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      if (msg.notification != null) {
        // You can show a local in-app dialog/snackbar or update UI
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(msg.notification!.title ?? ''),
            content: Text(msg.notification!.body ?? ''),
          ),
        );
      }
    });

    // Handle when user taps a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      final chatId = msg.data['chatId'];
      // Navigate to the chat screen:
      Navigator.pushNamed(context, '/chat', arguments: chatId);
    });
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('user_id');
    String? userRole = prefs.getString('role');

    if (userId != null && userRole != null) {
      // User is logged in, navigate to the appropriate page based on their role
      if (userRole == '1') {
        Navigator.of(context).pushReplacementNamed('main2');
      } else {
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
      theme: ThemeData(
        //pre-define input decoration
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Config.primaryColor,
          border: Config.outlinedBorder,
          focusedBorder: Config.focusBorder,
          errorBorder: Config.errorBorder,
          enabledBorder: Config.outlinedBorder,
          floatingLabelStyle: TextStyle(color: Config.primaryColor),
          prefixIconColor: Colors.black38,
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Config.primaryColor,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.grey.shade700,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => IntroScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        'main': (context) => const MainLayout(),
        'main2': (context) => const Main2Layout(),
        'doctor_details': (context) => const DoctorDetails(),
        'booking_page': (context) => BookingPage(),
        'success_booking': (context) => const AppointmentBooked(),
      },
    );
  }
}

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  RemoteNotification notification,
) async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'chat', // This is your custom channel ID (must be unique)
      'High Importance Notifications', // This is the name of your channel
      channelDescription:
          'This channel is used for important notifications.', // Description of the channel
      importance:
          Importance.max, // Maximum importance for high-priority notifications
      priority: Priority.high, // High priority for the notification
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      notification.title, // title
      notification.body, // body
      platformDetails, // notification details
    );

    debugPrint('Notification shown successfully.');
  } catch (e) {
    // If an error occurs, log it
    debugPrint('Error showing notification: $e');
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  // Add your custom logic here
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
