import 'package:doctor_appointment_app/components/register_form.dart';
import 'package:doctor_appointment_app/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/utils/text.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/components/login_form.dart';
//import 'package:doctor_appointment_app/components/social_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
             
              Text(
                AppText.enText['welcome_text']!,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Config.spaceSmall,
               const Spacer(),
              Text(
                AppText.enText['signIn_text']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Config.spaceSmall,
              // Center the LoginForm vertically with an Expanded widget
              const LoginForm(),
              Config.spaceSmall,
              const Spacer(), // Space at the bottom
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0), // Remove elevation
                  backgroundColor: WidgetStateProperty.all(
                      Colors.transparent), // Remove background color
                  shadowColor: WidgetStateProperty.all(
                      Colors.transparent), // Remove shadow
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
