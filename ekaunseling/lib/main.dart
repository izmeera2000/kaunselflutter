import 'package:doctor_appointment_app/screens/booking_page.dart';
import 'package:doctor_appointment_app/screens/doctor_details.dart';
import 'package:doctor_appointment_app/screens/succes_booked.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/screens/login_page.dart';
import 'package:doctor_appointment_app/screens/register_page.dart';
import 'package:doctor_appointment_app/screens/intro_page.dart';
import 'package:doctor_appointment_app/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('user_id');
    String? userRole = prefs.getString('role');

    if (userId != null && userRole != null) {
      // User is logged in, navigate to the appropriate page based on their role
      if (userRole == '1') {
        Navigator.of(context).pushReplacementNamed('main2');
      }  else {
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
      navigatorKey: navigatorKey,
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
