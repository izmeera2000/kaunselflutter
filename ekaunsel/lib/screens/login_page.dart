 import 'package:ekaunsel/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:ekaunsel/utils/text.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:ekaunsel/components/login_form.dart';
//import 'package:ekaunsel/components/social_button.dart';
import 'package:flutter/cupertino.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  DateTime? _lastPressedAt;


  Future<bool> _onWillPop(test, result) async {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      // If back button is pressed again within 2 seconds, exit the app
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      return Future.value(false); // Prevent default back button action
    }
    return Future.value(true); // Allow exit after second back press
  }




  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return PopScope(
      onPopInvokedWithResult: _onWillPop,
      canPop: false,
      child: Scaffold(
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
                      CupertinoPageRoute(
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
      ),
    );
  }
}
